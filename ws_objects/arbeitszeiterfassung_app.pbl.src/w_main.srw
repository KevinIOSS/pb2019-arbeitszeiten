$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type cb_delete from commandbutton within w_main
end type
type cb_new from commandbutton within w_main
end type
type cb_save from commandbutton within w_main
end type
type dw_arbeitszeitengrid from datawindow within w_main
end type
type cb_close from commandbutton within w_main
end type
type dw_arbeitszeiten from datawindow within w_main
end type
end forward

global type w_main from window
integer width = 6336
integer height = 2640
boolean titlebar = true
string title = "Arbeitszeiterfassung"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_delete cb_delete
cb_new cb_new
cb_save cb_save
dw_arbeitszeitengrid dw_arbeitszeitengrid
cb_close cb_close
dw_arbeitszeiten dw_arbeitszeiten
end type
global w_main w_main

type variables

end variables

on w_main.create
this.cb_delete=create cb_delete
this.cb_new=create cb_new
this.cb_save=create cb_save
this.dw_arbeitszeitengrid=create dw_arbeitszeitengrid
this.cb_close=create cb_close
this.dw_arbeitszeiten=create dw_arbeitszeiten
this.Control[]={this.cb_delete,&
this.cb_new,&
this.cb_save,&
this.dw_arbeitszeitengrid,&
this.cb_close,&
this.dw_arbeitszeiten}
end on

on w_main.destroy
destroy(this.cb_delete)
destroy(this.cb_new)
destroy(this.cb_save)
destroy(this.dw_arbeitszeitengrid)
destroy(this.cb_close)
destroy(this.dw_arbeitszeiten)
end on

event open;SQLCA.DBMS		= "ODBC"
SQLCA.Database	= "kevinsdb"
SQLCA.dbparm		= "Connectstring='DSN=kevinsdb;UID=dba;PWD=sql' DelimitIdentifier='YES' PBUseProcOwner='YES'"
SQLCA.userid		= "DBA"
SQLCA.dbpass		= "sql"

connect using SQLCA ; 

if SQLCA.SQLCode <> 0 then
	Messagebox ( "DB Connect","Verbindung zur Datenbank nicht aufgebaut")
else
	dw_arbeitszeiten.SetTransObject(SQLCA)
	dw_arbeitszeitengrid.SetTransObject(SQLCA)
	dw_arbeitszeitengrid.Retrieve()
	dw_arbeitszeitengrid.SetSort("arbeitstag A, beginn A, feierabend A, kennung A")
	dw_arbeitszeitengrid.Sort()
	dw_arbeitszeitengrid.Modify("ist_urlaub.Width = 300")
	dw_arbeitszeitengrid.Modify("ist_krank.Width = 300")
	dw_arbeitszeitengrid.Modify("ist_bei_kunde.Width = 500")
	dw_arbeitszeitengrid.Modify("beschreibung.Width = 1000")
end if



end event

type cb_delete from commandbutton within w_main
integer x = 914
integer y = 1740
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Löschen"
end type

event clicked;long row
row = dw_arbeitszeitengrid.GetSelectedRow(0)
IF row > 0 THEN
    IF MessageBox("Löschen", "Eintrag wirklich löschen?", Question!, YesNo!) = 1 THEN
        dw_arbeitszeitengrid.DeleteRow(row)
        IF dw_arbeitszeitengrid.Update() = 1 THEN
            COMMIT USING SQLCA;
			dw_arbeitszeiten.Reset()
        ELSE
            ROLLBACK USING SQLCA;
            MessageBox("Fehler", "Eintrag konnte nicht gelöscht werden.")
        END IF
    END IF
ELSE
    MessageBox("Hinweis", "Bitte zunächst einen Datensatz auswählen, der gelöscht werden soll.")
END IF
end event

type cb_new from commandbutton within w_main
integer x = 37
integer y = 1740
integer width = 402
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Neu"
end type

event clicked;// Gridzeile abwählen
dw_arbeitszeitengrid.SelectRow(0, FALSE)
dw_arbeitszeiten.Reset()
dw_arbeitszeiten.InsertRow(0)

// Defaults setzen
dw_arbeitszeiten.SetItem(1, "ist_urlaub", 0)
dw_arbeitszeiten.SetItem(1, "ist_krank", 0)
dw_arbeitszeiten.SetItem(1, "ist_bei_kunde", 0)
end event

type cb_save from commandbutton within w_main
integer x = 475
integer y = 1740
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Speichern"
end type

event clicked;long new_id, row, found, ll_kennung, ll_row, ll_grid_row, ll_grid_kennung, ll_cur_start, ll_cur_end, ll_grid_start, ll_grid_end, ll_offset_tage
string VPos, HPos, ls_arbeitstag
date ld_arbeitstag, ld_grid_arbeitstag
time lt_beginn, lt_feierabend, lt_grid_beginn, lt_grid_feierabend

// 1. Wurde überhaupt ein Datensatz angelegt/ausgewählt?
ll_row = dw_arbeitszeiten.GetRow()
IF ll_row = 0 THEN
	MessageBox("Hinweis", "Bitte zunächst über 'Neu' einen neuen Datensatz anlegen oder einen vorhandenen Datensatz auswählen.")
	RETURN
END IF

// 2. Datum geprüft
ld_arbeitstag = dw_arbeitszeiten.GetItemDate(ll_row, "arbeitstag")
IF IsNull(ld_arbeitstag) THEN
	MessageBox("Hinweis", "Bitte ein Datum auswählen.")
	RETURN
END IF

// 3. Überlappung + maximale Arbeitszeit (Mitternachts-Logik)
ll_kennung    = dw_arbeitszeiten.GetItemNumber(ll_row, "kennung")
lt_beginn     = dw_arbeitszeiten.GetItemTime(ll_row, "beginn")
lt_feierabend = dw_arbeitszeiten.GetItemTime(ll_row, "feierabend")

IF NOT IsNull(lt_beginn) AND NOT IsNull(lt_feierabend) THEN

	ll_cur_start = Hour(lt_beginn) * 60 + Minute(lt_beginn)
	ll_cur_end   = Hour(lt_feierabend) * 60 + Minute(lt_feierabend)
	IF ll_cur_end <= ll_cur_start THEN
		ll_cur_end += 1440
	END IF

	FOR ll_grid_row = 1 TO dw_arbeitszeitengrid.RowCount()
		ld_grid_arbeitstag = dw_arbeitszeitengrid.GetItemDate(ll_grid_row, "arbeitstag")
		ll_grid_kennung     = dw_arbeitszeitengrid.GetItemNumber(ll_grid_row, "kennung")

		IF IsNull(ld_grid_arbeitstag) OR ll_grid_kennung = ll_kennung THEN CONTINUE

		lt_grid_beginn     = dw_arbeitszeitengrid.GetItemTime(ll_grid_row, "beginn")
		lt_grid_feierabend = dw_arbeitszeitengrid.GetItemTime(ll_grid_row, "feierabend")
		IF IsNull(lt_grid_beginn) OR IsNull(lt_grid_feierabend) THEN CONTINUE

		ll_grid_start = Hour(lt_grid_beginn) * 60 + Minute(lt_grid_beginn)
		ll_grid_end   = Hour(lt_grid_feierabend) * 60 + Minute(lt_grid_feierabend)
		IF ll_grid_end <= ll_grid_start THEN
			ll_grid_end += 1440
		END IF

		ll_offset_tage = DaysAfter(ld_arbeitstag, ld_grid_arbeitstag)
		ll_grid_start += ll_offset_tage * 1440
		ll_grid_end   += ll_offset_tage * 1440

		IF ll_cur_start < ll_grid_end AND ll_grid_start < ll_cur_end THEN
			MessageBox("Überschneidung", &
				"Die eingegebene Zeit überschneidet sich mit einem bereits vorhandenen Eintrag am " + &
				String(ld_grid_arbeitstag, "dd.mm.yyyy") + " (" + &
				String(lt_grid_beginn, "hh:mm") + " - " + String(lt_grid_feierabend, "hh:mm") + &
				"). Bitte Zeit korrigieren.")
			RETURN
		END IF
	NEXT

	IF (ll_cur_end - ll_cur_start) > 600 THEN
		IF MessageBox("Maximale Arbeitszeit überschritten", &
				"Die eingetragene Arbeitszeit beträgt " + String((ll_cur_end - ll_cur_start) / 60.0, "0.0") + &
				" Stunden und überschreitet die maximal erlaubten 10 Stunden.~r~nTrotzdem übernehmen?", &
				Exclamation!, OKCancel!) = 2 THEN
			RETURN
		END IF
	END IF

END IF

// 4. Existiert der Eintrag schon? -> Überschreiben bestätigen
IF NOT IsNull(ll_kennung) AND ll_kennung > 0 THEN
	ls_arbeitstag = String(ld_arbeitstag, "dd.mm.yyyy")
	IF MessageBox("Überschreiben?", &
			"Für den Arbeitstag " + ls_arbeitstag + " existiert bereits ein Eintrag. Überschreiben?", &
			Question!, YesNo!) = 2 THEN
		RETURN
	END IF
END IF

dw_arbeitszeiten.AcceptText()
IF dw_arbeitszeiten.Update() = 1 THEN
    COMMIT USING SQLCA;
    new_id = dw_arbeitszeiten.GetItemNumber(1, "kennung")
    VPos = dw_arbeitszeitengrid.Describe("Datawindow.VerticalScrollPosition")
    HPos = dw_arbeitszeitengrid.Describe("Datawindow.HorizontalScrollPosition")
	dw_arbeitszeitengrid.SetTransObject(SQLCA)
	dw_arbeitszeitengrid.Retrieve()
	dw_arbeitszeitengrid.SetSort("arbeitstag A, beginn A, feierabend A, kennung A")
	dw_arbeitszeitengrid.Sort()

	found = 0
	FOR row = 1 TO dw_arbeitszeitengrid.RowCount()
		 IF dw_arbeitszeitengrid.GetItemNumber(row, "kennung") = new_id THEN
			  found = row
			  EXIT
		 END IF
	NEXT

	dw_arbeitszeitengrid.SelectRow(0, FALSE)
	IF found > 0 THEN
		 dw_arbeitszeitengrid.SelectRow(found, TRUE)
		 dw_arbeitszeitengrid.SetRow(found)
	END IF
    dw_arbeitszeitengrid.Modify("Datawindow.VerticalScrollPosition=" + VPos)
    dw_arbeitszeitengrid.Modify("Datawindow.HorizontalScrollPosition=" + HPos)
ELSE
    ROLLBACK USING SQLCA;
	MessageBox("Fehler", "Eintrag konnte nicht gelöscht werden.")
END IF
end event

type dw_arbeitszeitengrid from datawindow within w_main
integer x = 2446
integer y = 32
integer width = 3374
integer height = 1636
integer taborder = 20
string title = "none"
string dataobject = "griddw_sql_arbeitszeiten"
boolean hscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event clicked;if row > 0 then
	This.SelectRow(0,FALSE)
	This.SelectRow(row,TRUE)
end if
end event

event doubleclicked;IF row <= 0 THEN RETURN

dw_arbeitszeiten.SetTransObject(sqlca)
dw_arbeitszeiten.Retrieve(this.GetItemNumber(row, "kennung"))
end event

type cb_close from commandbutton within w_main
integer x = 1353
integer y = 1740
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Beenden"
end type

event clicked;close(Parent)
end event

type dw_arbeitszeiten from datawindow within w_main
integer x = 23
integer y = 20
integer width = 2080
integer height = 1652
integer taborder = 10
boolean bringtotop = true
string title = "none"
string dataobject = "dw_sql_arbeitszeiten"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event itemchanged;IF dwo.Name = "arbeitstag" THEN
    IF Len(data) <= 5 THEN
        this.SetItem(row, "arbeitstag", Date(data + "." + String(Year(Today()))))
    END IF
END IF

end event

event clicked;timepicker_struc TPS

IF dwo.Name = "beginn" OR dwo.Name = "feierabend" THEN
	TPS.dw_parent		= This
	TPS.actrow			= row
	TPS.actcol			= dwo.Name
	OpenWithParm(w_timepicker,TPS)
END IF
end event

