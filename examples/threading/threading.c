#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)
unsigned int function_calls;

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    thread_func_args->thread_complete_success = false;

    usleep((unsigned int) ((thread_func_args->wait_to_obtain_ms)*1000));
    thread_func_args->mutex_lock_rtrn_vle = pthread_mutex_lock(thread_func_args->mutex_info);
    if (thread_func_args->mutex_lock_rtrn_vle != 0)
    {
      return thread_func_args;
    }

    usleep((unsigned int) ((thread_func_args->wait_to_release_ms)*1000));
    thread_func_args->mutex_lock_rtrn_vle = pthread_mutex_unlock(thread_func_args->mutex_info);
    if (thread_func_args->mutex_lock_rtrn_vle != 0)
    {
      return thread_func_args;
    }
    
    thread_func_args->thread_complete_success = true;
    return thread_func_args;

}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments
    */
    struct thread_data *thread_data_inst               = calloc(1, sizeof(struct thread_data));
    if (NULL == thread_data_inst)
    {
      return false;
    }
    thread_data_inst[0].mutex_info              = mutex;
    thread_data_inst[0].thread_complete_success = false;
    thread_data_inst[0].wait_to_obtain_ms       = wait_to_obtain_ms;
    thread_data_inst[0].wait_to_release_ms      = wait_to_release_ms;
     /**
     * TODO: pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    if ( pthread_create(thread, NULL, threadfunc, thread_data_inst) != 0)
    {
      free(thread_data_inst);
      return false;
    }
    else
    {
      thread_data_inst[0].thread = thread;
      return true;
    }
}

