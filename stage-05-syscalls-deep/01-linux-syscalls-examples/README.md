## stage-05-syscalls-deep - 01-linux-syscalls-examples

Here’s a table of **the first \~60 essential Linux x86-64 syscalls**. (There are hundreds, but these cover most common usage.)

| #  | Syscall Name     | Purpose                     | Arguments (x86-64 Linux convention)                                           |
| -- | ---------------- | --------------------------- | ----------------------------------------------------------------------------- |
| 0  | `read`           | Read from file descriptor   | `rdi=fd`, `rsi=buf`, `rdx=count`                                              |
| 1  | `write`          | Write to file descriptor    | `rdi=fd`, `rsi=buf`, `rdx=count`                                              |
| 2  | `open`           | Open file                   | `rdi=filename`, `rsi=flags`, `rdx=mode`                                       |
| 3  | `close`          | Close file descriptor       | `rdi=fd`                                                                      |
| 4  | `stat`           | Get file status             | `rdi=filename`, `rsi=statbuf`                                                 |
| 5  | `fstat`          | Get file status by fd       | `rdi=fd`, `rsi=statbuf`                                                       |
| 6  | `lstat`          | Get symlink status          | `rdi=filename`, `rsi=statbuf`                                                 |
| 7  | `poll`           | Wait for events             | `rdi=fds`, `rsi=nfds`, `rdx=timeout`                                          |
| 8  | `lseek`          | Move file pointer           | `rdi=fd`, `rsi=offset`, `rdx=whence`                                          |
| 9  | `mmap`           | Map memory                  | `rdi=addr`, `rsi=length`, `rdx=prot`, `r10=flags`, `r8=fd`, `r9=offset`       |
| 10 | `mprotect`       | Change memory protection    | `rdi=addr`, `rsi=len`, `rdx=prot`                                             |
| 11 | `munmap`         | Unmap memory                | `rdi=addr`, `rsi=len`                                                         |
| 12 | `brk`            | Adjust program break (heap) | `rdi=new_brk`                                                                 |
| 13 | `rt_sigaction`   | Signal action               | `rdi=signum`, `rsi=act`, `rdx=oact`                                           |
| 14 | `rt_sigprocmask` | Modify signal mask          | `rdi=how`, `rsi=set`, `rdx=oset`                                              |
| 15 | `rt_sigreturn`   | Return from signal handler  | -                                                                             |
| 16 | `ioctl`          | Control device              | `rdi=fd`, `rsi=request`, `rdx=argp`                                           |
| 17 | `pread64`        | Read at offset              | `rdi=fd`, `rsi=buf`, `rdx=count`, `r10=offset`                                |
| 18 | `pwrite64`       | Write at offset             | `rdi=fd`, `rsi=buf`, `rdx=count`, `r10=offset`                                |
| 19 | `readv`          | Read multiple buffers       | `rdi=fd`, `rsi=iov`, `rdx=iovcnt`                                             |
| 20 | `writev`         | Write multiple buffers      | `rdi=fd`, `rsi=iov`, `rdx=iovcnt`                                             |
| 21 | `access`         | Check permissions           | `rdi=filename`, `rsi=mode`                                                    |
| 22 | `pipe`           | Create pipe                 | `rdi=pipefd`                                                                  |
| 23 | `select`         | Monitor file descriptors    | `rdi=nfds`, `rsi=readfds`, `rdx=writefds`, `r10=exceptfds`, `r8=timeout`      |
| 24 | `sched_yield`    | Yield CPU                   | -                                                                             |
| 25 | `mremap`         | Remap memory                | `rdi=old_addr`, `rsi=old_size`, `rdx=new_size`, `r10=flags`, `r8=new_addr`    |
| 26 | `msync`          | Synchronize memory          | `rdi=addr`, `rsi=len`, `rdx=flags`                                            |
| 27 | `mincore`        | Query resident pages        | `rdi=addr`, `rsi=len`, `rdx=vec`                                              |
| 28 | `madvise`        | Memory advice               | `rdi=addr`, `rsi=len`, `rdx=advice`                                           |
| 29 | `shmget`         | Shared memory               | `rdi=key`, `rsi=size`, `rdx=flags`                                            |
| 30 | `shmat`          | Attach shared memory        | `rdi=shmid`, `rsi=addr`, `rdx=flags`                                          |
| 31 | `shmctl`         | Control shared memory       | `rdi=shmid`, `rsi=cmd`, `rdx=buf`                                             |
| 32 | `dup`            | Duplicate fd                | `rdi=oldfd`                                                                   |
| 33 | `dup2`           | Duplicate fd                | `rdi=oldfd`, `rsi=newfd`                                                      |
| 34 | `pause`          | Wait for signal             | -                                                                             |
| 35 | `nanosleep`      | Sleep for time              | `rdi=req`, `rsi=rem`                                                          |
| 36 | `getitimer`      | Get timer                   | `rdi=which`, `rsi=curr_value`                                                 |
| 37 | `alarm`          | Set alarm                   | `rdi=seconds`                                                                 |
| 38 | `setitimer`      | Set timer                   | `rdi=which`, `rsi=new_value`, `rdx=old_value`                                 |
| 39 | `getpid`         | Get process ID              | -                                                                             |
| 40 | `sendfile`       | Send file to socket         | `rdi=out_fd`, `rsi=in_fd`, `rdx=offset`, `r10=count`                          |
| 41 | `socket`         | Create socket               | `rdi=domain`, `rsi=type`, `rdx=protocol`                                      |
| 42 | `connect`        | Connect socket              | `rdi=sockfd`, `rsi=addr`, `rdx=addrlen`                                       |
| 43 | `accept`         | Accept socket connection    | `rdi=sockfd`, `rsi=addr`, `rdx=addrlen`                                       |
| 44 | `sendto`         | Send to socket              | `rdi=sockfd`, `rsi=buf`, `rdx=len`, `r10=flags`, `r8=dest_addr`, `r9=addrlen` |
| 45 | `recvfrom`       | Receive from socket         | `rdi=sockfd`, `rsi=buf`, `rdx=len`, `r10=flags`, `r8=src_addr`, `r9=addrlen`  |
| 46 | `sendmsg`        | Send message                | `rdi=sockfd`, `rsi=msg`, `rdx=flags`                                          |
| 47 | `recvmsg`        | Receive message             | `rdi=sockfd`, `rsi=msg`, `rdx=flags`                                          |
| 48 | `shutdown`       | Shutdown socket             | `rdi=sockfd`, `rsi=how`                                                       |
| 49 | `bind`           | Bind socket                 | `rdi=sockfd`, `rsi=addr`, `rdx=addrlen`                                       |
| 50 | `listen`         | Listen on socket            | `rdi=sockfd`, `rsi=backlog`                                                   |
| 51 | `getsockname`    | Get socket name             | `rdi=sockfd`, `rsi=addr`, `rdx=addrlen`                                       |
| 52 | `getpeername`    | Get peer name               | `rdi=sockfd`, `rsi=addr`, `rdx=addrlen`                                       |
| 53 | `socketpair`     | Create socket pair          | `rdi=domain`, `rsi=type`, `rdx=protocol`, `r10=sv`                            |
| 54 | `setsockopt`     | Set socket option           | `rdi=sockfd`, `rsi=level`, `rdx=optname`, `r10=optval`, `r8=optlen`           |
| 55 | `getsockopt`     | Get socket option           | `rdi=sockfd`, `rsi=level`, `rdx=optname`, `r10=optval`, `r8=optlen`           |
| 56 | `clone`          | Create process/thread       | `rdi=flags`, `rsi=stack`, `rdx=ptid`, `r10=ctid`, `r8=newtls`                 |
| 57 | `fork`           | Create new process          | -                                                                             |
| 58 | `vfork`          | Fork but share memory       | -                                                                             |
| 59 | `execve`         | Execute program             | `rdi=filename`, `rsi=argv`, `rdx=envp`                                        |
| 60 | `exit`           | Exit process                | `rdi=status`                                                                  |

---

✅ **Notes:**

* Arguments are **passed in registers**: `RDI, RSI, RDX, R10, R8, R9`.
* Return value is always in `RAX`.
* Syscall numbers are **fixed for x86-64 Linux** (kernel interface).
