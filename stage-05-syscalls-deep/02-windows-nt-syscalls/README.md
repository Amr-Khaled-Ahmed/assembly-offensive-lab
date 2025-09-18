## stage-05-syscalls-deep - 02-windows-nt-syscalls

### **⚠️ Critical Warning: Windows vs. Linux Syscall Stability**

Unlike Linux, **Windows syscall numbers are not stable**. Microsoft does not guarantee them between versions or even different builds of the same OS (e.g., Windows 10 21H1 vs 21H2). They are an internal implementation detail.

*   **Linux:** Syscall numbers are part of the stable kernel ABI. `sys_write` is always `1`.
*   **Windows:** The number for `NtWriteFile` can change with any system update.

**Therefore, direct syscalls are used primarily for evasion in security research (e.g., malware, pentesting tools) and not for general application development.** The stable way to call these functions is through their exported wrappers in `ntdll.dll` (e.g., `call NtWriteFile`).

The numbers below are **examples** from a common Windows 10 build and will likely need to be gathered fresh for your target.

---

## stage-05-syscalls-deep - 02-windows-syscalls-examples

Here’s a table of **~60 essential Windows x86-64 syscalls** (based on common Windows 10/11 builds). These are the low-level "NT" functions that the official Windows API (e.g., `Kernel32.dll`) ultimately calls.

| #  | Syscall Name            | Purpose                                 | Arguments (x86-64 Windows convention)                                                                                             | High-Level API Equivalent |
| -- | ----------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| 0  | `NtAcceptConnectPort`   | Accept connection request               | `rcx=PortHandle`, `rdx=PortContext`, `r8=ConnectRequest`, `r9=Accept`, `rsp+0x28=ConnectionMsg`, `rsp+0x30=ConnectHandle`         |                           |
| 1  | `NtAccessCheck`         | Validate access rights                  | `rcx=SecurityDescriptor`, `rdx=ClientToken`, `r8=DesiredAccess`, `r9=GenericMapping`                                              |                           |
| 2  | `NtAccessCheckAndAuditAlarm` | Check access & log alarm          | `rcx=SubsystemName`, `rdx=HandleId`, `r8=ObjectTypeName`, `r9=ObjectName`                                                         |                           |
| 3  | `NtAddAtom`             | Add atom to table                       | `rcx=Atom`, `rdx=String`                                                                                                          | `AddAtom`                 |
| 4  | `NtAddBootEntry`        | Add boot entry                          | `rcx=BootEntry`, `rdx=Id`                                                                                                         |                           |
| 5  | `NtAddDriverEntry`      | Add driver entry                        | `rcx=DriverEntry`, `rdx=Id`                                                                                                       |                           |
| 6  | `NtAdjustGroupsToken`   | Adjust token groups                     | `rcx=TokenHandle`, `rdx=ResetToDefault`, `r8=NewState`, `r9=BufferLength`                                                         |                           |
| 7  | `NtAdjustPrivilegesToken` | Adjust token privileges               | `rcx=TokenHandle`, `rdx=DisableAllPrivileges`, `r8=NewState`, `r9=BufferLength`                                                   | `AdjustTokenPrivileges`   |
| 8  | `NtAlertResumeThread`   | Alert and resume thread                 | `rcx=ThreadHandle`, `rdx=PreviousSuspendCount`                                                                                    |                           |
| 9  | `NtAlertThread`         | Alert a thread                          | `rcx=ThreadHandle`                                                                                                                |                           |
| 10 | `NtAllocateLocallyUniqueId` | Allocate LUID                     | `rcx=Luid`                                                                                                                        | `AllocateLocallyUniqueId` |
| 11 | `NtAllocateReserveObject` | Allocate reserve memory object      | `rcx=ProcessHandle`, `rdx=ObjectAttributes`, `r8=ObjectType`                                                                      |                           |
| 12 | `NtAllocateUserPhysicalPages` | Allocate physical pages           | `rcx=ProcessHandle`, `rdx=NumberOfPages`, `r8=PageArray`                                                                          |                           |
| 13 | `NtAllocateUuids`       | Allocate UUIDs                         | `rcx=UuidLastTime`, `rdx=UuidSeed`, `r8=UuidSequenceNumber`, `r9=UuidGenerated`                                                   | `UuidCreate`              |
| 14 | `NtAllocateVirtualMemory` | **Allocate virtual memory**         | `rcx=ProcessHandle`, `rdx=BaseAddress`, `r8=ZeroBits`, `r9=RegionSize`, `rsp+0x28=AllocationType`, `rsp+0x30=Protect`             | `VirtualAlloc[Ex]`        |
| 15 | `NtAlpcAcceptConnectPort` | ALPC accept connection               | `rcx=PortHandle`, `rdx=Flags`, `r8=ObjectAttributes`, `r9=RequiredServerSid`                                                      |                           |
| 16 | `NtAlpcCancelMessage`   | ALPC cancel message                    | `rcx=PortHandle`, `rdx=Flags`, `r8=MessageContext`                                                                                |                           |
| 17 | `NtAlpcConnectPort`     | ALPC connect to port                   | `rcx=PortHandle`, `rdx=PortName`, `r8=ObjectAttributes`, `r9=PortAttributes`                                                      |                           |
| 18 | `NtAlpcCreatePort`      | ALPC create port                       | `rcx=PortHandle`, `rdx=ObjectAttributes`, `r8=PortAttributes`                                                                     |                           |
| 19 | `NtAlpcCreatePortSection` | ALPC create port section             | `rcx=PortHandle`, `rdx=Flags`, `r8=SectionHandle`, `r9=SectionSize`                                                               |                           |
| 20 | `NtAlpcCreateResourceReserve` | ALPC create resource reserve     | `rcx=PortHandle`, `rdx=Flags`, `r8=RequiredSize`                                                                                  |                           |
| 21 | `NtAlpcCreateSectionView` | ALPC create section view            | `rcx=PortHandle`, `rdx=Flags`, `r8=ViewAttributes`                                                                                |                           |
| 22 | `NtAlpcCreateSecurityContext` | ALPC create security context      | `rcx=PortHandle`, `rdx=Flags`, `r8=SecurityContext`                                                                               |                           |
| 23 | `NtAlpcDeletePortSection` | ALPC delete port section            | `rcx=PortHandle`, `rdx=Flags`, `r8=SectionContext`                                                                                |                           |
| 24 | `NtAlpcDeleteResourceReserve` | ALPC delete resource reserve      | `rcx=PortHandle`, `rdx=Flags`, `r8=ResourceContext`                                                                               |                           |
| 25 | `NtAlpcDeleteSectionView` | ALPC delete section view            | `rcx=PortHandle`, `rdx=Flags`, `r8=ViewContext`                                                                                   |                           |
| 26 | `NtAlpcDeleteSecurityContext` | ALPC delete security context      | `rcx=PortHandle`, `rdx=Flags`, `r8=SecurityContext`                                                                               |                           |
| 27 | `NtAlpcDisconnectPort`  | ALPC disconnect port                  | `rcx=PortHandle`, `rdx=Flags`                                                                                                     |                           |
| 28 | `NtAlpcImpersonateClientOfPort` | ALPC impersonate client           | `rcx=PortHandle`, `rdx=PortMessage`, `r8=Flags`                                                                                   |                           |
| 29 | `NtAlpcOpenSenderProcess` | ALPC open sender process            | `rcx=PortHandle`, `rdx=PortMessage`, `r8=Flags`, `r9=ProcessHandle`                                                               |                           |
| 30 | `NtAlpcOpenSenderThread` | ALPC open sender thread             | `rcx=PortHandle`, `rdx=PortMessage`, `r8=Flags`, `r9=ThreadHandle`                                                                |                           |
| 31 | `NtAlpcQueryInformation` | ALPC query information              | `rcx=PortHandle`, `rdx=PortInformationClass`, `r8=PortInformation`, `r9=Length`                                                   |                           |
| 32 | `NtAlpcQueryInformationMessage` | ALPC query info message         | `rcx=PortHandle`, `rdx=Flags`, `r8=Message`, `r9=MessageInformationClass`                                                         |                           |
| 33 | `NtAlpcRevokeSecurityContext` | ALPC revoke security context      | `rcx=PortHandle`, `rdx=Flags`, `r8=SecurityContext`                                                                               |                           |
| 34 | `NtAlpcSendWaitReceivePort` | ALPC send/wait/receive           | `rcx=PortHandle`, `rdx=Flags`, `r8=SendMessage`, `r9=SendMessageAttributes`                                                       |                           |
| 35 | `NtAlpcSetInformation`  | ALPC set information                  | `rcx=PortHandle`, `rdx=PortInformationClass`, `r8=PortInformation`, `r9=Length`                                                   |                           |
| 36 | `NtAreMappedFilesTheSame` | Check if two maps are same file    | `rcx=File1`, `rdx=File2`                                                                                                          |                           |
| 37 | `NtAssignProcessToJobObject` | Assign process to job              | `rcx=JobHandle`, `rdx=ProcessHandle`                                                                                              | `AssignProcessToJobObject`|
| 38 | `NtCancelIoFile`        | Cancel I/O operations                 | `rcx=FileHandle`, `rdx=IoRequest`                                                                                                 | `CancelIo`                |
| 39 | `NtCancelIoFileEx`      | Cancel I/O operations (extended)      | `rcx=FileHandle`, `rdx=IoRequestToCancel`, `r8=IoStatusBlock`                                                                     | `CancelIoEx`              |
| 40 | `NtCancelSynchronousIoFile` | Cancel synchronous I/O            | `rcx=ThreadHandle`, `rdx=IoRequestToCancel`, `r8=IoStatusBlock`                                                                   |                           |
| 41 | `NtCancelTimer`         | **Cancel timer**                      | `rcx=TimerHandle`, `rdx=PreviousState`                                                                                            | `CancelWaitableTimer`     |
| 42 | `NtClearEvent`          | Clear event                            | `rcx=EventHandle`                                                                                                                 | `ResetEvent`              |
| 43 | `NtClose`               | **Close handle**                      | `rcx=Handle`                                                                                                                      | `CloseHandle`             |
| 44 | `NtCompleteConnectPort` | Complete port connection              | `rcx=PortHandle`                                                                                                                  |                           |
| 45 | `NtConnectPort`         | Connect to port                       | `rcx=PortHandle`, `rdx=PortName`, `r8=SecurityQos`, `r9=WriteSection`                                                             |                           |
| 46 | `NtContinue`            | Continue execution                    | `rcx=Context`, `rdx=TestAlert`                                                                                                    |                           |
| 47 | `NtCreateDebugObject`   | Create debug object                   | `rcx=DebugObjectHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=Flags`                                                   |                           |
| 48 | `NtCreateDirectoryObject` | Create directory object             | `rcx=DirectoryHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`                                                                 |                           |
| 49 | `NtCreateEvent`         | **Create event**                      | `rcx=EventHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=EventType`                                                     | `CreateEvent[Ex]`         |
| 50 | `NtCreateEventPair`     | Create event pair                     | `rcx=EventPairHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`                                                                 |                           |
| 51 | `NtCreateFile`          | **Create/open file**                  | `rcx=FileHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=IoStatusBlock`, `rsp+0x28=...` (11 args total)                  | `CreateFile`              |
| 52 | `NtCreateIoCompletion`  | Create I/O completion port           | `rcx=IoCompletionHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=Count`                                                  | `CreateIoCompletionPort`  |
| 53 | `NtCreateJobObject`     | Create job object                     | `rcx=JobHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`                                                                       | `CreateJobObject`         |
| 54 | `NtCreateKey`           | Create registry key                   | `rcx=KeyHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=TitleIndex`                                                      | `RegCreateKeyEx`          |
| 55 | `NtCreateKeyTransacted` | Create transacted registry key       | `rcx=KeyHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=TitleIndex`                                                      |                           |
| 56 | `NtCreateMailslotFile`  | Create mailslot                      | `rcx=FileHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=IoStatusBlock`                                                   |                           |
| 57 | `NtCreateMutant`        | Create mutex                         | `rcx=MutantHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=InitialOwner`                                                  | `CreateMutex[Ex]`         |
| 58 | `NtCreateNamedPipeFile` | Create named pipe                    | `rcx=FileHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=IoStatusBlock`                                                   | `CreateNamedPipe`         |
| 59 | `NtCreatePagingFile`    | Create paging file                   | `rcx=PageFileName`, `rdx=InitialSize`, `r8=MaximumSize`, `r9=Reserved`                                                            |                           |
| 60 | `NtCreatePort`          | Create port                          | `rcx=PortHandle`, `rdx=ObjectAttributes`, `r8=MaxDataSize`, `r9=MaxMessageSize`                                                   |                           |
| 61 | `NtCreateProcess`       | **Create process**                    | `rcx=ProcessHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=ParentProcess`                                                | `CreateProcess`           |
| 62 | `NtCreateProcessEx`     | Create process (extended)            | `rcx=ProcessHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=ParentProcess`                                                |                           |
| 63 | `NtCreateProfile`       | Create profile                       | `rcx=ProfileHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=Base`                                                        |                           |
| 64 | `NtCreateSection`       | **Create memory section**            | `rcx=SectionHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=MaximumSize`                                                 | `CreateFileMapping`       |
| 65 | `NtCreateSemaphore`     | Create semaphore                     | `rcx=SemaphoreHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=InitialCount`                                               | `CreateSemaphore[Ex]`     |
| 66 | `NtCreateSymbolicLinkObject` | Create symbolic link            | `rcx=SymbolicLinkHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=TargetName`                                             |                           |
| 67 | `NtCreateThread`        | **Create thread**                     | `rcx=ThreadHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=ProcessHandle`                                                 | `CreateThread`            |
| 68 | `NtCreateTimer`         | Create timer                         | `rcx=TimerHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=TimerType`                                                     | `CreateWaitableTimer`     |
| 69 | `NtCreateToken`         | Create token                         | `rcx=TokenHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=Type`                                                          |                           |
| 70 | `NtCreateUserProcess`   | Create user process                  | `rcx=ProcessHandle`, `rdx=ThreadHandle`, `r8=DesiredProcessAccess`, `r9=DesiredThreadAccess`                                      |                           |
| 71 | `NtDebugActiveProcess`  | Debug active process                 | `rcx=ProcessHandle`, `rdx=DebugObjectHandle`                                                                                      |                           |
| 72 | `NtDebugContinue`       | Continue debug event                 | `rcx=DebugObjectHandle`, `rdx=ClientId`, `r8=ContinueStatus`                                                                      |                           |
| 73 | `NtDelayExecution`      | **Sleep**                            | `rcx=Alertable`, `rdx=DelayInterval`                                                                                              | `Sleep[Ex]`               |
| 74 | `NtDeleteAtom`          | Delete atom                          | `rcx=Atom`                                                                                                                        | `DeleteAtom`              |
| 75 | `NtDeleteBootEntry`     | Delete boot entry                    | `rcx=Id`                                                                                                                          |                           |
| 76 | `NtDeleteDriverEntry`   | Delete driver entry                  | `rcx=Id`                                                                                                                          |                           |
| 77 | `NtDeleteFile`          | Delete file                          | `rcx=ObjectAttributes`                                                                                                            | `DeleteFile`              |
| 78 | `NtDeleteKey`           | Delete registry key                  | `rcx=KeyHandle`                                                                                                                   | `RegDeleteKey`            |
| 79 | `NtDeleteObjectAuditAlarm` | Delete object audit alarm         | `rcx=ObjectTypeName`, `rdx=ObjectHandle`                                                                                          |                           |
| 80 | `NtDeleteValueKey`      | Delete registry value               | `rcx=KeyHandle`, `rdx=ValueName`                                                                                                  | `RegDeleteValue`          |
| 81 | `NtDeviceIoControlFile` | **Device I/O control**               | `rcx=FileHandle`, `rdx=Event`, `r8=ApcRoutine`, `r9=ApcContext`, `rsp+0x28=IoStatusBlock` (10 args total)                          | `DeviceIoControl`         |
| 82 | `NtDisplayString`       | Display string on debug terminal     | `rcx=String`                                                                                                                      |                           |
| 83 | `NtDuplicateObject`     | **Duplicate handle**                 | `rcx=SourceProcessHandle`, `rdx=SourceHandle`, `r8=TargetProcessHandle`, `r9=TargetHandle`                                        | `DuplicateHandle`         |
| 84 | `NtDuplicateToken`      | Duplicate token                      | `rcx=ExistingTokenHandle`, `rdx=DesiredAccess`, `r8=ObjectAttributes`, `r9=EffectiveOnly`                                         | `DuplicateToken[Ex]`      |
| 85 | `NtEnumerateKey`        | Enumerate registry subkeys          | `rcx=KeyHandle`, `rdx=Index`, `r8=KeyInformationClass`, `r9=KeyInformation`                                                       | `RegEnumKeyEx`            |
| 86 | `NtEnumerateValueKey`   | Enumerate registry values           | `rcx=KeyHandle`, `rdx=Index`, `r8=KeyValueInformationClass`, `r9=KeyValueInformation`                                             | `RegEnumValue`            |
| 87 | `NtExtendSection`       | Extend memory section               | `rcx=SectionHandle`, `rdx=NewSectionSize`                                                                                         |                           |
| 88 | `NtFilterToken`         | Filter token                        | `rcx=ExistingTokenHandle`, `rdx=Flags`, `r8=SidsToDisable`, `r9=PrivilegesToDelete`                                               |                           |
| 89 | `NtFindAtom`            | Find atom                           | `rcx=String`, `rdx=Atom`                                                                                                          | `FindAtom`                |
| 90 | `NtFlushBuffersFile`    | Flush file buffers                  | `rcx=FileHandle`, `rdx=IoStatusBlock`                                                                                             | `FlushFileBuffers`        |
| 91 | `NtFlushInstructionCache` | Flush CPU instruction cache       | `rcx=ProcessHandle`, `rdx=BaseAddress`, `r8=Length`                                                                               |                           |
| 92 | `NtFlushKey`            | Flush registry key                  | `rcx=KeyHandle`                                                                                                                   | `RegFlushKey`             |
| 93 | `NtFlushVirtualMemory`  | Flush virtual memory                | `rcx=ProcessHandle`, `rdx=BaseAddress`, `r8=FlushSize`, `r9=IoStatus`                                                             |                           |
| 94 | `NtFlushWriteBuffer`    | Flush write buffer                  | -                                                                                                                                 |                           |
| 95 | `NtFreeUserPhysicalPages` | Free physical pages               | `rcx=ProcessHandle`, `rdx=NumberOfPages`, `r8=PageArray`                                                                          |                           |
| 96 | `NtFreeVirtualMemory`   | **Free virtual memory**             | `rcx=ProcessHandle`, `rdx=BaseAddress`, `r8=RegionSize`, `r9=FreeType`                                                            | `VirtualFree[Ex]`         |
| 97 | `NtFreezeRegistry`      | Freeze registry                     | `rcx=TimeOutInSeconds`                                                                                                            |                           |
| 98 | `NtFreezeTransactions`  | Freeze transactions                 | `rcx=FreezeTimeout`, `rdx=ThawTimeout`                                                                                            |                           |
| 99 | `NtFsControlFile`       | File system control                 | `rcx=FileHandle`, `rdx=Event`, `r8=ApcRoutine`, `r9=ApcContext`, `rsp+0x28=IoStatusBlock` (10 args total)                          |                           |
| 100| `NtGetContextThread`    | Get thread context                  | `rcx=ThreadHandle`, `rdx=Context`                                                                                                 | `GetThreadContext`        |
| ... | ... | ... | ... | ... |

---

### **Key Differences from Linux x86-64:**

1.  **Calling Convention:** Windows uses a different register order for parameters: `RCX`, `RDX`, `R8`, `R9`, then stack. Linux uses `RDI`, `RSI`, `RDX`, `R10`, `R8`, `R9`.
2.  **Syscall Instruction:** Both use `syscall`, but the mechanism to set up the call is different.
3.  **Stability:** **This is the most important difference.** Linux numbers are stable, Windows numbers are volatile.
4.  **Naming:** Windows syscalls are prefixed with `Nt` or `Zw`.
5.  **Complexity:** Windows syscalls often have more parameters and more complex structures.

To use these, you must first write a function to dynamically resolve the correct syscall number from `ntdll.dll` for the current version of Windows.

Here are the best places to find and search for Windows syscall information:

### 1. The Ultimate Source: Windows Research Kernel (WRK) and Leaks

While not for the latest Windows 11, historical leaks provide the most authoritative insight into the core NT architecture.

*   **Windows Research Kernel (WRK):** A partially leaked, older, but official source code base for the Windows NT kernel that Microsoft shared with academia. It contains the definitive syscall table and function prototypes for that era.
    *   **What to search for:** `"WRK" "Windows Research Kernel" download`
*   **NT Internals Books:** Books like *Windows Internals* by Pavel Yosifovich, Alex Ionescu, Mark Russinovich, and David Solomon are the bible for this. They explain the concepts but don't list every single syscall number as they change too often.

### 2. Best Online Resources & Repositories (Most Practical)

These are maintained by researchers and are your best bet for getting current information.

*   **j00ru/windows-syscalls (GitHub):** This is arguably the **most important resource** for this topic.
    *   **Link:** [https://github.com/j00ru/windows-syscalls](https://github.com/j00ru/windows-syscalls)
    *   **What it is:** A massive, ongoing project that meticulously documents syscall numbers across **every single version of Windows NT** (x86, x64, ARM). It provides tables, scripts, and data dumps. If you need to know the number for `NtCreateFile` on Windows 10 20H2, this is where you find it.

*   **Syscalls Explorer (Website):** A fantastic, user-friendly website built on top of the data from j00ru's repository.
    *   **Link:** [https://syscalls.mebeim.net/](https://syscalls.mebeim.net/)
    *   **What it is:** A web interface that allows you to select your Windows version and architecture and browse the complete syscall table. It's much easier to use than raw CSV files from GitHub.

*   **NTAPI Undocumented Functions (Website):**
    *   **Link:** [http://undocumented.ntinternals.net/](http://undocumented.ntinternals.net/)
    *   **What it is:** A classic, older resource that provides a list of many `Nt*` and `Zw*` functions with their parameters. It's less focused on syscall numbers and more on function prototypes. Great for understanding what parameters a function expects.

### 3. How to Find Information Yourself (Dynamic Analysis)

Since the numbers change, the most reliable way for your specific machine is to look them up yourself.

*   **Dumping from ntdll.dll:** The `ntdll.dll` library in Windows contains the "official" user-mode stub for each syscall. Each function (e.g., `NtCreateFile`) contains the correct `syscall` instruction and the number for that OS build.
    *   **How to do it:** You can write a simple C or C++ program (or even a PowerShell script) that:
        1.  Loads `ntdll.dll` (`LoadLibrary` or `GetModuleHandle`).
        2.  Gets the address of a function like `NtCreateFile` (`GetProcAddress`).
        3.  Disassembles the first few bytes of the function to find the `mov eax, SSN` instruction (where `SSN` is the System Service Number).
    *   **Tools:** Many open-source tools do this automatically. Search for **"SSN Syscall Number Resolver"** or **"HellsGate / HalosGate"** implementations on GitHub. These are techniques used in security tools to dynamically find syscall numbers.

### Search Terms to Use:

When you are looking for more information, use these specific terms in your searches:

*   `"Windows syscall table"`
*   `"NT system service number"`
*   `"j00ru syscalls"` (the main researcher)
*   `"SSN resolver"` or `"Syscall Number Resolver"`
*   `"Direct System Calls"` (techniques for using them)
*   `"HellsGate HalosGate"` (evasion techniques that rely on finding syscalls)
*   `"Windows Native API"` (the official term for the `Nt*` functions in `ntdll.dll`)

**In summary: For a complete, version-specific list, your number one stop should be the GitHub repository [`j00ru/windows-syscalls`](https://github.com/j00ru/windows-syscalls) or the website [Syscalls Explorer](https://syscalls.mebeim.net/) that's built from it.** This is how professionals and researchers get accurate, up-to-date information.
