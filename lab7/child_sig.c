#include <signal.h>
#include <stdio.h>

void handle_sigusr1(int sig);

// void sig_handler(int sig)
//{
//    printf("Handling the signal by process %d\n", getpid());
//}


main()
{
    if (fork()){
        // this is the parent
	printf("Parent: %d\n", getpid());
        signal(SIGUSR1, &handle_sigusr1);
    }
    else {
        // this is the child
	printf("Child: %d\n", getpid());
 //       execlp("./test", "./test", 0)
        //signal(SIGINT, SIG_IGN);
    }
    pause();
}

void handle_sigusr1(int sig)
{
  printf("Received a SIGUSR1!!\n");
  char *args[]={"./test", NULL};
  execvp(args[0], args);
}
