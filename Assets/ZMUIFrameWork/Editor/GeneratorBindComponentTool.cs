using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class GeneratorBindComponentTool : Editor
{

    public static List<EditorObjectData> objDataList;//查找对象的数据

    [MenuItem("GameObject/生成组件数据脚本(Shift+B) #B", false, 0)]
    static void CreateFindComponentScripts()
    {
        GameObject obj = Selection.objects.FirstOrDefault() as GameObject;//获取到当前选择的物体
        if (obj == null)
        {
            Debug.LogError("需要选择 GameObject");
            return;
        }
        objDataList = new List<EditorObjectData>();

        //设置脚本生成路径
        if (!Directory.Exists(GeneratorConfig.BindComponentGeneratorPath))
        {
            Directory.CreateDirectory(GeneratorConfig.BindComponentGeneratorPath);
        }
        //解析窗口组件数据
        if (GeneratorConfig.ParseType == ParseType.Tag)
            ParseWindowDataByTag(obj.transform, obj.name);
        else
            PresWindowNodeData(obj.transform, obj.name);


        //储存字段名称
        string datalistJson = JsonConvert.SerializeObject(objDataList);
        PlayerPrefs.SetString(GeneratorConfig.OBJDATALIST_KEY, datalistJson);
        //生成CS脚本
        string csContnet = CreateCS(obj.name);
        Debug.Log("CsConent:\n" + csContnet);
        string cspath = GeneratorConfig.BindComponentGeneratorPath + "/" + obj.name + "DataComponent.cs";
        int targetID = obj.GetInstanceID();
        string className = obj.name + "DataComponent";
        UIWindowEditor.ShowWindow(csContnet, cspath, onScriptSaved: () =>
        {
            EditorPrefs.SetString("GeneratorClassName", className);
            SessionState.SetInt("GeneratorTargetID", targetID);
            SessionState.SetString("GeneratorBindingData", datalistJson);
            // Also handles regeneration when Unity does not need to reload scripts.
            EditorApplication.delayCall += BindPendingComponents;
        });
    }
    /// <summary>
    /// 解析窗口节点数据
    /// </summary>
    /// <param name="trans"></param>
    /// <param name="WinName"></param>
    public static void PresWindowNodeData(Transform trans, string WinName)
    {
        for (int i = 0; i < trans.childCount; i++)
        {
            GameObject obj = trans.GetChild(i).gameObject;
            string name = obj.name;
            if (GeneratorConfig.TryParseComponentName(name, out string fieldType, out string fieldName))
            {
                objDataList.Add(new EditorObjectData { fieldName = fieldName, fieldType = fieldType, insID = obj.GetInstanceID() });
            }
            PresWindowNodeData(trans.GetChild(i), WinName);
        }
    }
    public static void ParseWindowDataByTag(Transform trans, string WinName)
    {
        for (int i = 0; i < trans.childCount; i++)
        {
            GameObject obj = trans.GetChild(i).gameObject;
            string tagName = obj.tag;
            if (GeneratorConfig.TAGArr.Contains(tagName))
            {
                string fieldName = obj.name;//获取字段昵称
                string fieldType = tagName;//获取字段类型
                objDataList.Add(new EditorObjectData { fieldName = fieldName, fieldType = fieldType, insID = obj.GetInstanceID() });
            }
            ParseWindowDataByTag(trans.GetChild(i), WinName);
        }
    }
    public static string CreateCS(string name)
    {
        StringBuilder sb = new StringBuilder();
        string nameSpaceName = "ZMUIFrameWork";
        //添加引用
        sb.AppendLine("/*---------------------------------");
        sb.AppendLine(" *Title:UI自动化组件生成代码生成工具");
        sb.AppendLine(" *Author:铸梦");
        sb.AppendLine(" *Date:" + System.DateTime.Now);
        sb.AppendLine(" *Description:变量需要以[Text]括号加组件类型的格式进行声明，然后右键窗口物体—— 一键生成UI数据组件脚本即可");
        sb.AppendLine(" *注意:以下文件是自动生成的，任何手动修改都会被下次生成覆盖,若手动修改后,尽量避免自动生成");
        sb.AppendLine("---------------------------------*/");
        sb.AppendLine("using UnityEngine.UI;");
        sb.AppendLine("using UnityEngine;");
        sb.AppendLine("using TMPro;");

        sb.AppendLine();

        //生成命名空间
        if (!string.IsNullOrEmpty(nameSpaceName))
        {
            sb.AppendLine($"namespace {nameSpaceName}");
            sb.AppendLine("{");
        }
        sb.AppendLine($"\tpublic class {name + "Data" + "Component:MonoBehaviour"}");
        sb.AppendLine("\t{");

        //根据字段数据列表 声明字段
        foreach (var item in objDataList)
        {
            sb.AppendLine("\t\tpublic   " + item.fieldType + "  " + item.fieldName + item.fieldType + ";\n");
        }

        //声明初始化组件接口
        sb.AppendLine("\t\tpublic  void InitComponent(WindowBase target)");
        sb.AppendLine("\t\t{");

        sb.AppendLine("\t\t     //组件事件绑定");
        //得到逻辑类 WindowBase => LoginWindow
        sb.AppendLine($"\t\t     {name} mWindow=({name})target;");

        //生成UI事件绑定代码
        foreach (var item in objDataList)
        {
            string type = item.fieldType;
            string methodName = item.fieldName;
            string suffix = "";
            if (type.Contains("Button"))
            {
                suffix = "Click";
                sb.AppendLine($"\t\t     target.AddButtonClickListener({methodName}{type},mWindow.On{methodName}Button{suffix});");
            }
            if (type.Contains("InputField"))
            {
                sb.AppendLine($"\t\t     target.AddInputFieldListener({methodName}{type},mWindow.On{methodName}InputChange,mWindow.On{methodName}InputEnd);");
            }
            if (type.Contains("Toggle"))
            {
                suffix = "Change";
                sb.AppendLine($"\t\t     target.AddToggleClickListener({methodName}{type},mWindow.On{methodName}Toggle{suffix});");
            }
        }
        sb.AppendLine("\t\t}");
        sb.AppendLine("\t}");
        if (!string.IsNullOrEmpty(nameSpaceName))
        {
            sb.AppendLine("}");
        }
        return sb.ToString();
    }

    public static EditorObjectData GetEditorObjectData(int insid)
    {
        foreach (var item in objDataList)
        {
            if (item.insID == insid)
            {
                return item;
            }
        }
        return null;
    }
    /// <summary>
    /// 编译完成系统自动调用
    /// </summary>
    [UnityEditor.Callbacks.DidReloadScripts]
    public static void AddComponent2Window()
    {
        // Wait until scene and Prefab Stage objects have been restored after reload.
        EditorApplication.delayCall += BindPendingComponents;
    }

    private static void BindPendingComponents()
    {
        if (EditorApplication.isCompiling || EditorApplication.isUpdating)
        {
            EditorApplication.delayCall += BindPendingComponents;
            return;
        }
        //如果当前不是生成数据脚本的回调，就不处理
        string className = EditorPrefs.GetString("GeneratorClassName");
        if (string.IsNullOrEmpty(className))
        {
            return;
        }
        //1.通过反射的方式，从程序集中找到这个脚本，把它挂在到当前的物体上
        //获取所有的程序集
        var assemblies = AppDomain.CurrentDomain.GetAssemblies();
        //找到Csharp程序集
        var cSharpAssembly = assemblies.First(assembly => assembly.GetName().Name == "Assembly-CSharp");
        //获取类所在的程序集路径
        string relClassName = "ZMUIFrameWork." + className;
        Type type = cSharpAssembly.GetType(relClassName);
        if (type == null)
        {
            return;
        }

        //获取要挂载的那个物体
        string windowObjName = className.Replace("DataComponent", "");
        int targetID = SessionState.GetInt("GeneratorTargetID", 0);
        GameObject windowObj = EditorUtility.InstanceIDToObject(targetID) as GameObject;
        // Compatibility with pending generations created before target tracking was added.
        if (windowObj == null && targetID == 0)
            windowObj = GameObject.Find(windowObjName);
        if (windowObj == null)
        {
            if (targetID == 0)
                windowObj = GameObject.Find("UIRoot/" + windowObjName);
            if (windowObj == null)
            {
                Debug.LogWarning("自动绑定未完成：生成时选择的窗口已关闭或删除，请重新选择窗口并生成组件数据脚本。");
                EditorPrefs.DeleteKey("GeneratorClassName");
                return;
            }
        }
        //先获取现窗口上有没有挂载该数据组件，如果没挂载在进行挂载
        Component compt = windowObj.GetComponent(type);
        if (compt == null)
        {
            compt = Undo.AddComponent(windowObj, type);
        }
        //2.通过反射的方式，遍历数据列表 找到对应的字段，赋值
        //获取对象数据列表
        string datalistJson = SessionState.GetString("GeneratorBindingData", PlayerPrefs.GetString(GeneratorConfig.OBJDATALIST_KEY));
        List<EditorObjectData> objDataList = JsonConvert.DeserializeObject<List<EditorObjectData>>(datalistJson);
        if (objDataList == null)
        {
            Debug.LogError("自动绑定失败：组件数据不存在，请重新生成组件数据脚本。", windowObj);
            return;
        }
        Undo.RecordObject(compt, "绑定 UI 组件");
        //获取脚本所有字段
        FieldInfo[] fieldInfoList = type.GetFields();

        foreach (var item in fieldInfoList)
        {
            foreach (var objData in objDataList)
            {
                if (item.Name == objData.fieldName + objData.fieldType)
                {
                    //根据Insid找到对应的对象
                    GameObject uiObject = EditorUtility.InstanceIDToObject(objData.insID) as GameObject;
                    if (uiObject == null)
                    {
                        Debug.LogWarning("自动绑定失败：找不到节点 " + objData.fieldName + "，请重新生成组件数据脚本。", windowObj);
                        continue;
                    }
                    //设置该字段所对应的对象
                    if (string.Equals(objData.fieldType, "GameObject"))
                    {
                        item.SetValue(compt, uiObject);
                    }
                    else
                    {
                        Component value = uiObject.GetComponent(item.FieldType);
                        if (value == null)
                            Debug.LogWarning("节点 " + uiObject.name + " 上没有 " + item.FieldType.Name + " 组件，请检查节点的类型标记。", uiObject);
                        item.SetValue(compt, value);
                    }
                    break;
                }
            }
        }

        EditorUtility.SetDirty(compt);
        if (PrefabUtility.IsPartOfPrefabInstance(compt))
            PrefabUtility.RecordPrefabInstancePropertyModifications(compt);
        if (windowObj.scene.IsValid() && windowObj.scene.isLoaded)
            EditorSceneManager.MarkSceneDirty(windowObj.scene);
        EditorPrefs.DeleteKey("GeneratorClassName");
        SessionState.EraseInt("GeneratorTargetID");
        SessionState.EraseString("GeneratorBindingData");
        Debug.Log("组件自动绑定完成：" + windowObj.name + "，请保存场景或 Prefab。", windowObj);
    }
}
