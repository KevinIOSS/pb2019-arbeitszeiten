$PBExportHeader$w_timepicker.srw
forward
global type w_timepicker from window
end type
type cb_ok from commandbutton within w_timepicker
end type
type lb_minuten from listbox within w_timepicker
end type
type lb_stunden from listbox within w_timepicker
end type
end forward

global type w_timepicker from window
integer width = 1024
integer height = 772
boolean titlebar = true
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
cb_ok cb_ok
lb_minuten lb_minuten
lb_stunden lb_stunden
end type
global w_timepicker w_timepicker

type variables
timepicker_struc TPS
end variables
on w_timepicker.create
this.cb_ok=create cb_ok
this.lb_minuten=create lb_minuten
this.lb_stunden=create lb_stunden
this.Control[]={this.cb_ok,&
this.lb_minuten,&
this.lb_stunden}
end on

on w_timepicker.destroy
destroy(this.cb_ok)
destroy(this.lb_minuten)
destroy(this.lb_stunden)
end on

event open;integer i

TPS = message.PowerObjectParm

this.X = PointerX()
this.Y = PointerY()

FOR i = 0 TO 23
    lb_stunden.AddItem(String(i, "00"))
NEXT

FOR i = 0 TO 55 STEP 5
    lb_minuten.AddItem(String(i, "00"))
NEXT
end event

type cb_ok from commandbutton within w_timepicker
integer x = 727
integer y = 548
integer width = 251
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "OK"
end type

event clicked;string hh, mm

hh = lb_stunden.SelectedItem()
mm = lb_minuten.SelectedItem()

TPS.dw_parent.SetItem(TPS.ActRow, TPS.ACtCol, time ( hh + ":" + mm) )


Close(Parent)
end event

type lb_minuten from listbox within w_timepicker
integer x = 677
integer width = 302
integer height = 500
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type lb_stunden from listbox within w_timepicker
integer x = 288
integer width = 302
integer height = 500
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

