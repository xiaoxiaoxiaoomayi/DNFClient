using UnityEngine;
using System.Collections;

public class OffsetChange : MonoBehaviour
{
    #region varaible
    public float LoopCount=1;
    public float AStartTime = 0;
    public float AXSpeed = 0;
    public float AYSpeed = 1;
    public float BStartTime = 3;
    public float BXSpeed = 0;
    public float BYSpeed = 1;

    float xoffset = -1;
    float yoffset = -1;
	float prevXoffset=-10;
    float prevYoffset=-10;
	bool bFirstEnter=true;
	float timer=0;
	Material UseMaterial;

    public bool ignoreTimeScale = false;

    [HideInInspector]    public float _LoopCount;
    [HideInInspector]    public float _AStartTime;
    [HideInInspector]    public float _AXSpeed;
    [HideInInspector]    public float _AYSpeed;
    [HideInInspector]    public float _BStartTime;
    [HideInInspector]    public float _BXSpeed;
    [HideInInspector]    public float _BYSpeed;
    [HideInInspector]    public float _xoffset;
    [HideInInspector]    public float _yoffset;
    [HideInInspector]    public float _prevXoffset;
    [HideInInspector]    public float _prevYoffset;
    [HideInInspector]    public bool _bFirstEnter;
    [HideInInspector]    public float _timer;
    [HideInInspector]    public Material _UseMaterial;

    #endregion

    #region Init Params
    void Awake()
    {
        Memory();
    }

/*    public void Reset()
    {
        LoopCount = _LoopCount;
        AStartTime = _AStartTime;
        AXSpeed = _AXSpeed;
        AYSpeed = _AYSpeed;
        BStartTime = _BStartTime;
        BXSpeed = _BXSpeed;
        BYSpeed = _BYSpeed;
        yoffset = _yoffset;
        xoffset = _xoffset;
        prevXoffset = _prevXoffset;
        prevYoffset = _prevYoffset;
        bFirstEnter = _bFirstEnter;
        timer = _timer;
        UseMaterial = _UseMaterial;

        Start();
    }*/

    void Memory()
    {
        _LoopCount = LoopCount;
        _AStartTime = AStartTime;
        _AXSpeed = AXSpeed;
        _AYSpeed = AYSpeed;
        _BStartTime = BStartTime;
        _BXSpeed = BXSpeed;
        _BYSpeed = BYSpeed;
        _yoffset = yoffset;
        _xoffset = xoffset;
        _prevXoffset = prevXoffset;
        _prevYoffset = prevYoffset;
        _bFirstEnter = bFirstEnter;
        _timer = timer;
        _UseMaterial = UseMaterial;
    }

	void Start ()
	{
		UseMaterial = GetComponent<Renderer>().material;
		if(AXSpeed>0) xoffset=-1;
		else if(AXSpeed<0) xoffset=1;
		else xoffset=0;
        if(AYSpeed>0) yoffset=-1;
		else if(AYSpeed<0) yoffset=1;
		else yoffset=0;
	}
    #endregion
	// Update is called once per frame
	void Update () 
	{
        if (null == UseMaterial) 
        {
            return ;
        }

        //float delta = ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
        float delta = ignoreTimeScale ? Time.deltaTime : Time.deltaTime;

		timer+=delta;
		if(LoopCount <= 0)
		{
			xoffset+=delta*AXSpeed;
			yoffset+=delta*AYSpeed;
			if(xoffset>1) xoffset=-1;
			if(yoffset>1) yoffset=-1;
			if(xoffset<-1) xoffset=1;
			if(yoffset<-1) yoffset=1;
		}
		else if(LoopCount==1)
		{
			if(timer >= AStartTime)
			{
				xoffset += delta * AXSpeed;
 		        yoffset += delta* AYSpeed;
				if(xoffset>1) xoffset=1;
				if(xoffset<-1) xoffset=-1;
				if(yoffset>1) yoffset=1;
				if(yoffset<-1) yoffset=-1;
			}
		}
		else
		{
			if(timer<AStartTime)
			{
				
			}
			else if (timer < BStartTime)
            {
                xoffset += delta * AXSpeed;
                yoffset += delta * AYSpeed;
                if(xoffset>1) xoffset=1;
				if(xoffset<-1) xoffset=-1;
				if(yoffset>1) yoffset=1;
				if(yoffset<-1) yoffset=-1;
            }
            else
            {
				if(bFirstEnter)
				{
					if(BXSpeed>0) xoffset=-1;
		            else if(BXSpeed<0) xoffset=1;
		            else xoffset=0;
                    if(BYSpeed>0) yoffset=-1;
		            else if(BYSpeed<0) yoffset=1;
		            else yoffset=0;
					bFirstEnter=false;
				}
                xoffset += delta * BXSpeed;
                yoffset += delta * BYSpeed;
                if(xoffset>1) xoffset=1;
				if(xoffset<-1) xoffset=-1;
				if(yoffset>1) yoffset=1;
				if(yoffset<-1) yoffset=-1;
            }
		}
        if(prevXoffset!=xoffset||prevYoffset!=yoffset)
            UseMaterial.SetTextureOffset("_MainTex", new Vector2(xoffset, yoffset));
        prevXoffset = xoffset;
        prevYoffset = yoffset;
	}
}
