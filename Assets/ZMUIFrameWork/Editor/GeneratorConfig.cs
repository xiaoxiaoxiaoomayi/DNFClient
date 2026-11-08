using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text.RegularExpressions;

public enum GeneratorType
{
    Find,//组件查找
    Bind,//组件绑定
}
public enum ParseType
{
    Name,
    Tag
}
public class GeneratorConfig
{
    // Only explicit [ComponentType]FieldName markers are bindings; TMP submesh names contain brackets too.
    private static readonly Regex ComponentNamePattern = new Regex(
        @"^\[(?<type>[\p{L}_][\p{L}\p{N}_]*)\](?<field>[\p{L}_][\p{L}\p{N}_]*)$");

    public static bool TryParseComponentName(string name, out string fieldType, out string fieldName)
    {
        Match match = ComponentNamePattern.Match(name);
        fieldType = match.Groups["type"].Value;
        fieldName = match.Groups["field"].Value;
        return match.Success;
    }

    public static string BindComponentGeneratorPath = Application.dataPath + "/ZMUIFrameWork/Scripts/BindCompoent";
    public static string FindComponentGeneratorPath = Application.dataPath + "/ZMUIFrameWork/Scripts/FindCompoent";
    public static string WindowGeneratorPath = Application.dataPath + "/ZMUIFrameWork/Scripts/Window";
    public static string OBJDATALIST_KEY = "objDataList";
    public static GeneratorType GeneratorType = GeneratorType.Bind;
    public static ParseType ParseType = ParseType.Name;
    public static string[] TAGArr = { "Text","TextPro", "ZM_EmojiTextPro", "Image","RawImage","Button","InputField", "Toggle","Slider","Scrollbar","DropDown",
    "Canvas","Panel","ScrollRect","LoopListView2","Transform","RectTransform","GameObject",
    "TMP_Text","TextMeshProUGUI","TextMeshPro","TMP_InputField","TMP_Dropdown"};
}
