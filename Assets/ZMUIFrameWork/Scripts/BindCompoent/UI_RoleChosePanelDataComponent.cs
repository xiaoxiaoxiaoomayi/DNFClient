/*---------------------------------
 *Title:UI自动化组件生成代码生成工具
 *Author:铸梦
 *Date:2026/10/31 17:45:16
 *Description:变量需要以[Text]括号加组件类型的格式进行声明，然后右键窗口物体—— 一键生成UI数据组件脚本即可
 *注意:以下文件是自动生成的，任何手动修改都会被下次生成覆盖,若手动修改后,尽量避免自动生成
---------------------------------*/
using UnityEngine.UI;
using UnityEngine;
using TMPro;

namespace ZMUIFrameWork
{
	public class UI_RoleChosePanelDataComponent:MonoBehaviour
	{
		public   Image  bgImage;

		public   Image  titleImage;

		public   Button  enterBtnButton;

		public   TMP_InputField  nameInputTMP_InputField;

		public  void InitComponent(WindowBase target)
		{
		     //组件事件绑定
		     UI_RoleChosePanel mWindow=(UI_RoleChosePanel)target;
		     target.AddButtonClickListener(enterBtnButton,mWindow.OnenterBtnButtonClick);
		     target.AddInputFieldListener(nameInputTMP_InputField,mWindow.OnnameInputInputChange,mWindow.OnnameInputInputEnd);
		}
	}
}
