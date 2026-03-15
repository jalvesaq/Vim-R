
function OkularJobStdout(job_id, data, etype)
    for cmd in a:data
        if cmd =~ "^call "
            exe cmd
        endif
    endfor
endfunction

function OkularJobStdoutV(job_id, msg)
    let cmd = substitute(a:msg, '\n', '', 'g')
    let cmd = substitute(cmd, '\r', '', 'g')
    if cmd =~ "^call "
        exe cmd
    endif
endfunction

function StartOkularVim(fullpath)
    let jobid = job_start(["okular", "--unique",
                \ "--editor-cmd", "echo 'call SyncTeX_backward(\"%f\",  \"%l\")'", a:fullpath],
                \ {"stoponexit": "", "out_cb": function("OkularJobStdoutV")})
    if job_info(jobid)["status"] == "run"
        let g:rplugin.jobs["Okular"] = job_getchannel(jobid)
    else
        call RWarningMsg("Failed to run Okular...")
    endif
endfunction

function ROpenPDF2(fullpath)
    call StartOkularVim(a:fullpath)
endfunction

function SyncTeX_forward2(tpath, ppath, texln, tryagain)
    let texname = substitute(a:tpath, ' ', '\\ ', 'g')
    let pdfname = substitute(a:ppath, ' ', '\\ ', 'g')
    let jobid = job_start(["okular", "--unique",
                \ "--editor-cmd", "echo 'call SyncTeX_backward(\"%f\",  \"%l\")'",
                \ pdfname . "#src:" . a:texln . texname],
                \ {"stoponexit": "", "out_cb": function("OkularJobStdoutV")})
    if job_info(jobid)["status"] == "run"
        let g:rplugin.jobs["OkularSyncTeX"] = job_getchannel(jobid)
    else
        call RWarningMsg("Failed to run Okular (SyncTeX forward)...")
    endif
    if g:rplugin.has_awbt
        call RRaiseWindow(pdfname)
    endif
endfunction
