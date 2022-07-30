
#SingleInstance Force

;Menu, Tray, NoStandard
Menu, Tray, NoIcon
SkillCooldownTimeConf := loadSkillCooldownTimeConf()
if (!SkillCooldownTimeConf) {
	MsgBox, "配置文件加载失败！"
	ExitApp
}
comboboxContent := ""
For key, value in SkillCooldownTimeConf
{
	if (1 == A_Index) {
		comboboxContent := comboboxContent key
		continue
	}
	comboboxContent := comboboxContent "|" key
}

Menu, FileMenu, Add, 打开, OpenFile
Gui, Menu, FileMenu

Gui, Add, Text, x10 y10 w460 h15 HwndShowFileNameText
Gui, Add, GroupBox, x30 y30 w340 h60, 冷却时间(单位:秒)

Gui, Add, ComboBox, disabled Sort gCooldownTimeGuiControl vSkillSelect1 HwndSkillSelect1Hwnd x40 y50 w160 h240, %comboboxContent%
Gui, Add, Edit, disabled x215 y50 w60 h20 HwndCooldownTimeEdit
Gui, Add, Button, x285 y50 w50 h20 vModifyBtn gCooldownTimeGuiControl, 修改
Gui, Show, w400 h200, 1715技能修改
return


GuiClose:
if (SkillObj) {
	SkillObj.close()
}
ExitApp

OpenFile:
FileSelectFile, fName, 3, libskill.so, 打开libskill.so,*.so
if ("" != fName) {
	GuiControl, Text, %ShowFileNameText%, %fName%
	GuiControl, Enable, %SkillSelect1Hwnd%
	GuiControl, Enable, %CooldownTimeEdit%
	SkillObj := new ModifySkill(fName)
}
return

CooldownTimeGuiControl:
	if (!SkillObj) {
		ToolTip, 请先打开文件, 35, 35
		SetTimer, RemoveToolTip, -5000
		return
	}
	switch A_GuiControl
	{
		case "SkillSelect1":
			GuiControlGet, skillStr, ,%SkillSelect1Hwnd%
			index := 0 + SkillCooldownTimeConf[skillStr]
			if (index <= 0) {
				;MsgBox, 发生异常，无法修改！
				return
			}
			r := SkillObj.seek(index).getInt() // 1000
			GuiControl, , %CooldownTimeEdit%, %r%
		case "ModifyBtn":
			GuiControlGet, skillStr, ,%SkillSelect1Hwnd%
			index := 0 + SkillCooldownTimeConf[skillStr]
			if (index <= 0) {
				MsgBox, 发生异常，无法修改！
				return
			}
			GuiControlGet, cooldownTime, ,%CooldownTimeEdit%
			cooldownTime := Floor(cooldownTime * 1000)
			if (cooldownTime <= 0) {
				MsgBox, 发生异常，无法修改！
				return
			}
			SkillObj.seek(index).setInt(cooldownTime)
			ToolTip, 修改成功
			SetTimer, RemoveToolTip, -5000

	}
return

RemoveToolTip:
ToolTip
return

loadSkillCooldownTimeConf() {
	FileRead, content, .\SkillCooldownTimeConf.txt
	if (ErrorLevel or !content) {
		return
	}
	obj := {}
	Loop, Parse, content, `n, `r
	{
		arr := StrSplit(A_LoopField, ",")
		if (2 != arr.Length()) {
			continue
		}
		obj[arr[1]] := arr[2]
	}
	return obj
}

class ModifySkill
{
	__New(fileName) {
		this.file := FileOpen(fileName, "rw")
        return this  ; 使用 'new' 运算符时可以省略此行.
	}
	__Delete() {
		this.close()
	}
	close() {
		if (this.file) {
			this.file.Close()
		}
	}
	seek(index) {
		this.file.seek(index)
		return this
	}
	getInt() {
		return this.file.readInt()
	}
	getFloat() {
		return this.file.readInt()
	}
	getDouble() {
		return this.file.readInt()
	}
	setInt(value) {
		this.file.writeInt(value)
		return this
	}
	setFloat(value) {
		this.file.writeFloat(value)
		return this
	}
	setDouble(value) {
		this.file.writeDouble(value)
		return this
	}
}

