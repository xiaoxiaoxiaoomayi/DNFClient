using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using ZMGC.Battle;
using ZMGC.Hall;
using ZM.AssetFrameWork;
public class Main : MonoBehaviour
{
    public static Main Instance;
    // Start is called before the first frame update
    void Start()
    {
        Instance = this;
        ZMAssetsFrame.Instance.InitFrameWork();
        UIModule.Instance.Initialize();
        WorldManager.CreateWorld<HallWorld>();

        
        DontDestroyOnLoad(gameObject);
    }

    public void LoadSceneAsync()
    {
        UIModule.Instance.PopUpWindow<LoadingWindow>();
        StartCoroutine(AsyncLoadScene());
    }

    IEnumerator AsyncLoadScene()
    {
        AsyncOperation operation=SceneManager.LoadSceneAsync("Battle");
        //默认不激活场景
        operation.allowSceneActivation = false;

        float curProgress = 0;
        float maxprogress = 100;
        //unity场景加载进度只会从  0-0.9，0.9-1需要代码去做平滑过度
        while (curProgress<90)
        {
            curProgress=operation.progress*100.0f;
            UIEventControl.DispensEvent(UIEventEnum.UpdateSceneProgress,curProgress);
            //等一个空帧为了让UI有渲染过程
            yield return null;
        }

        while (curProgress < maxprogress)
        {
            curProgress++;
            UIEventControl.DispensEvent(UIEventEnum.UpdateSceneProgress,curProgress);
            //等一个空帧为了让UI有渲染过程
            yield return null;
        }
        
        operation.allowSceneActivation = true;
        yield return null;
        //创建英雄
        
        UIModule.Instance.DestroyAllWindow();

        WorldManager.CreateWorld<BattleWorld>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    /// <summary>
    /// 资源解压完成后调用
    /// </summary>
    public void StartGame()
    {
    }
}
