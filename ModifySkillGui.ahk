
#SingleInstance Force

SkillCooldownTimeConf := loadSkillCooldownTimeConf()
if (!SkillCooldownTimeConf) {
	MsgBox,,提示, "配置文件加载失败！"
	ExitApp
}

SkillOtherConf := loadSkillOtherConf()
if (!SkillOtherConf) {
	MsgBox,,提示, "配置文件加载失败！"
	ExitApp
}
comboboxContent1 := ""
For key, value in SkillCooldownTimeConf
{
	if (1 == A_Index) {
		comboboxContent1 := comboboxContent1 key
		continue
	}
	comboboxContent1 := comboboxContent1 "|" key
}
comboboxContent2 := ""
For key, value in SkillOtherConf
{
	if (1 == A_Index) {
		comboboxContent2 := comboboxContent2 key
		continue
	}
	comboboxContent2 := comboboxContent2 "|" key
}


;Menu, Tray, NoStandard
Menu, Tray, NoIcon

Menu, FileMenu, Add, 打开, OpenFile
Menu, FileMenu, Add, 帮助, Help
Gui, Menu, FileMenu

Gui, Add, Text, x10 y10 w460 h15 HwndShowFileNameText
Gui, Add, GroupBox, x20 y30 w340 h60, 冷却时间(单位:秒)
Gui, Add, ComboBox, disabled Sort gModifySkillGuiControl vSkillSelect1 HwndSkillSelect1Hwnd x35 y50 w160 h240, %comboboxContent1%
Gui, Add, Edit, disabled x215 y50 w60 h20 HwndCooldownTimeEdit
Gui, Add, Button, x285 y50 w50 h20 vModifyBtn1 gModifySkillGuiControl, 修改

Gui, Add, GroupBox, x20 y95 w340 h80, 其他修改
Gui, Add, ComboBox, disabled Sort gModifySkillGuiControl vSkillSelect2 HwndSkillSelect2Hwnd x35 y115 w160 h240, %comboboxContent2%
Gui, Add, Edit, disabled x215 y115 w60 h20 HwndOtherEdit
Gui, Add, Button, x285 y115 w50 h20 vModifyBtn2 gModifySkillGuiControl, 修改
Gui, Add, Text, x30 y145 w460 h15 HwndShowSkillOtherText, 修改描述
Gui, Show, w400 h200, 1715技能修改
return


GuiClose:
if (FileObj) {
	FileObj.close()
}
ExitApp

Help:
MsgBox, , 提示, 修改前请先备份文件！！！`n1.复制服务端文件(/home/1715x1/lib/libskill.so)到本地`n2.打开文件，修改`n3.上传替换服务端文件
return

OpenFile:
FileSelectFile, fName, 3, libskill.so, 打开libskill.so,*.so
if ("" != fName) {
	GuiControl, Text, %ShowFileNameText%, %fName%
	GuiControl, Enable, %SkillSelect1Hwnd%
	GuiControl, Enable, %CooldownTimeEdit%
	GuiControl, Enable, %SkillSelect2Hwnd%
	GuiControl, Enable, %OtherEdit%
	FileObj := new ModifyFile(fName)
}
return

ModifySkillGuiControl:
	if (!FileObj) {
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
				return
			}
			r := FileObj.getInt(index) // 1000
			GuiControl, , %CooldownTimeEdit%, %r%
		case "ModifyBtn1":
			GuiControlGet, skillStr, ,%SkillSelect1Hwnd%
			index := 0 + SkillCooldownTimeConf[skillStr]
			if (index <= 0) {
				MsgBox,,提示, 发生异常，无法修改！
				return
			}
			GuiControlGet, cooldownTime, ,%CooldownTimeEdit%
			cooldownTime := Floor(cooldownTime * 1000)
			FileObj.setInt(index, cooldownTime)
			ToolTip, 修改成功
			SetTimer, RemoveToolTip, -5000
		case "SkillSelect2":
			GuiControlGet, skillStr, ,%SkillSelect2Hwnd%
			index := 0 + SkillOtherConf[skillStr].addr
			if (index <= 0) {
				return
			}
			type := SkillOtherConf[skillStr].type
			r := FileObj.getByType(index, type)
			desc := SkillOtherConf[skillStr].desc
			GuiControl, , %OtherEdit%, %r%
			GuiControl, , %ShowSkillOtherText%, %desc%
		case "ModifyBtn2":
			GuiControlGet, skillStr, ,%SkillSelect2Hwnd%
			index := 0 + SkillOtherConf[skillStr].addr
			if (index <= 0) {
				MsgBox,,提示, 发生异常，无法修改！
				return
			}
			type := SkillOtherConf[skillStr].type
			GuiControlGet, inputValue, ,%OtherEdit%
			FileObj.setByType(index, type, inputValue)
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


loadSkillOtherConf() {
	FileRead, content, .\SkillOtherConf.txt
	if (ErrorLevel or !content) {
		return
	}
	obj := {}
	Loop, Parse, content, `n, `r
	{
		arr := StrSplit(A_LoopField, ";")
		if (4 != arr.Length()) {
			continue
		}
		obj[arr[1]] := {"name":arr[1], "desc": arr[2], "type": arr[3], "addr": arr[4]}
	}
	return obj
}

class ModifyFile
{
	__New(fileName) {
		this.fileName := fileName
        return this  ; 使用 'new' 运算符时可以省略此行.
	}
	__Delete() {
		this.close()
	}
	getFile() {
		if IsObject(this.file) {
			return this.file
		}
		this.file := FileOpen(this.fileName, "rw")
		return this.file
	}
	close() {
		if IsObject(this.file) {
			this.file.Close()
		}
		this.file := ""
	}
	getInt(index) {
		file := this.getFile()
		file.seek(index)
		return file.readInt()
	}
	getFloat(index) {
		file := this.getFile()
		file.seek(index)
		return file.readFloat()
	}
	getDouble(index) {
		file := this.getFile()
		file.seek(index)
		return file.readDouble()
	}
	setInt(index, value) {
		file := this.getFile()
		file.seek(index)
		file.writeInt(value)
		this.close()
		return this
	}
	setFloat(index, value) {
		file := this.getFile()
		file.seek(index)
		file.writeFloat(value)
		this.close()
		return this
	}
	setDouble(index, value) {
		file := this.getFile()
		file.seek(index)
		file.writeDoubule(value)
		this.close()
		return this
	}
	getByType(index, type) {
		switch (type) {
			case "int":
				return this.getInt(index)
			case "float":
				return this.getFloat(index)
			case "double":
				return this.getDouble(index)
		}
	}
	setByType(index, type, value) {
		switch (type) {
			case "int":
				return this.setInt(index, value)
			case "float":
				return this.setFloat(index, value)
			case "double":
				return this.setDouble(index, value)
		}
	}
}

