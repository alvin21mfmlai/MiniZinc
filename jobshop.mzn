% Data variables %
int: machinesCount; % Number of machines
int: jobsCount; % Number of jobs
int: tasksPerJob = machinesCount; % Each job has one task per machine
set of int: jobs = 1..jobsCount; % Job indexing
set of int: tasks = 1..tasksPerJob; % Task indexing

% Data structures %
array [jobs, tasks] of 0..(machinesCount-1): jobTaskMachine; % jobTaskMachine[j, k] is the machine required by task k of job j
array [jobs, tasks] of int: jobTaskDuration; % jobTaskDuration[k, j] is the duration of task k of job j

int: minDuration = max([sum([jobTaskDuration[i, j] | j in tasks]) | i in jobs]); % minimal duration : bounds on end time
int: maxDuration = sum([jobTaskDuration[i, j] | i in jobs, j in tasks]); % maximum duration : bounds on end time

array [jobs, tasks] of var 0.. maxDuration: jobTaskStart; % The start time of each job task
var minDuration..maxDuration: t_end; % The finishing time is the time of the last task to complete

% Constraints %
constraint
    forall (j in jobs, k in tasks)(jobTaskDuration[j, k] >= 0); % Tasks cannot take a negative amount of time 
constraint
    forall (j in jobs, k in 1..(tasksPerJob - 1))(jobTaskStart[j, k] + jobTaskDuration[j, k] <= jobTaskStart[j, k + 1]); % Each job task must complete before the next
constraint
    forall (j in jobs) (jobTaskStart[j, 1] >= 0); % The first job task can start no earlier than time step 0
constraint
    forall 
    (
        ja in jobs,
        jb in (ja + 1)..jobsCount,
        ka, kb in tasks
    ) 
    (
        if jobTaskMachine[ja, ka]  =  jobTaskMachine[jb, kb]
        then
            no_overlap
            ( 
                jobTaskStart[ja, ka], jobTaskDuration[ja, ka], jobTaskStart[jb, kb], jobTaskDuration[jb, kb] % Tasks on the same machine cannot overlap
            )
        else true
        endif
    );
predicate no_overlap(var int: t_a, var int: d_a, var int: t_b, var int: d_b)  = ( t_a + d_a  <=  t_b )  \/  ( t_b + d_b  <=  t_a );

% The finishing time must be no earlier than the finishing time of any task %
constraint
    forall ( j in jobs) (jobTaskStart[j, tasksPerJob] + jobTaskDuration[j, tasksPerJob] <= t_end);

% Optimization function %
solve minimize t_end;
output ["jobTaskStart = ", show(jobTaskStart), "\n","t_end = ", show(t_end), "\n"];