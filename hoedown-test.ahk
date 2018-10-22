#NoEnv
SetBatchLines -1
SetWorkingDir %A_ScriptDir%

dllFile := (A_PtrSize=8) ? "x64\hoedown.dll" : "hoedown.dll"
DllCall("LoadLibrary", "Str", dllFile, "Ptr")

renderer := hoedown_html_renderer_new(0, 0)
document := hoedown_document_new(renderer, 0, 16)

html := hoedown_buffer_new(16)
hoedown_document_render(document, html, "**bold** *italic*")

data := NumGet(html + 0)
size := NumGet(html + A_PtrSize, "uint")
result := StrGet(data, size, "UTF-8")
MsgBox, % result

hoedown_buffer_free(html)
hoedown_document_free(document)
hoedown_html_renderer_free(renderer)

hoedown_html_renderer_new(render_flags := 0, nesting_level := 0) {
	return DllCall("hoedown\hoedown_html_renderer_new"
		, "uint", render_flags
		, "int", nesting_level
		, "ptr")
}

hoedown_document_new(renderer, extensions, max_nesting) {
	return DllCall("hoedown\hoedown_document_new"
		, "ptr", renderer
		, "uint", extensions
		, "uint", max_nesting
		, "ptr")
}

hoedown_buffer_new(unit) {
	return DllCall("hoedown\hoedown_buffer_new", "uint", unit, "ptr")
}

hoedown_document_render(hoedown_document, hoedown_buffer, ByRef data, size := "") {
	size := StrPutVar(data, dataA, "UTF-8")
	DllCall("hoedown\hoedown_document_render"
		, "ptr", hoedown_document
		, "ptr", hoedown_buffer
		, "ptr", &dataA
		, "uint", size)
}

hoedown_buffer_free(buf) {
	DllCall("hoedown\hoedown_buffer_free", "ptr", buf)
}

hoedown_document_free(doc) {
	DllCall("hoedown\hoedown_document_free", "ptr", doc)
}

hoedown_html_renderer_free(renderer) {
	DllCall("hoedown\hoedown_html_renderer_free", "ptr", renderer)
}

StrPutVar(string, ByRef var, encoding)
{
	; Ensure capacity.
	VarSetCapacity( var, StrPut(string, encoding)
		; StrPut returns char count, but VarSetCapacity needs bytes.
		* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
	; Copy or convert the string.
	return StrPut(string, &var, encoding)
}