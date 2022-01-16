%Initialize network
X = input("Hello\n\nEnter the System's Criticality Level : ");
%fprintf("Level = %dn",X);

n = input("Enter number of Tasks: ");


r = zeros(n,1);
d = zeros(n,1);
p = zeros(n,1);

C = zeros(n, X);

x = zeros(n,1);
c = zeros(n, X);

hp=1;		%HyperPeriod
nj=0;		%Denotes number of Jobs
max=0;

for i = 1:n
    fprintf("\n\tFor Task %d", i);
    r(i) = input("\nRelease Time : ");
    d(i) = input("Deadline : ");
    
    p(i) = d(i) - r(i);
    if hp > p(i)
        max = hp;
    else
        max = p(i);
    end
    
    while(mod(max,hp)==0 && mod(max,p(i))==0)
        max = max +1;
    end
    hp = max;

    while 1
        x(i) = input("Criticality : ");
        if(x(i)>2)
            fprintf("\n!!Criticality Greater than 2 not accepted. Please try again!\n\n");
        else
            break;
        end
    end
    for j = 1:(ceil(x(i)))
        fprintf("WCET at level %d:",j)
        C(i, j) = input("");
    end
end
fprintf("\n\n-----------------Entry Completed---------------\n");
fprintf("HyperPeriod : %d\n", hp);

for i = 1:n
	nj = nj+ (hp/p(i));
end
nj=ceil(nj);
fprintf("Total Num of Jobs: %d\n",nj);

r = zeros(nj,1);
d = zeros(nj,1);
p = zeros(nj,1);

task = zeros(nj,1);

C = zeros(nj, X);

x = zeros(nj,1);
c = zeros(nj, X);

%fprintf("Reached after redeclaration");
%fflush(stdout);

counter = 0;
%Populating all the jobs
for i = 1:n
    %fprintf("Going for i = %d, Counter= %d\n",i,counter);
    %fflush(stdout);
    task(i) = i;
    for j = 1:ceil(hp/p(i))
        %fprintf("Going for j = %d, So Job num = %d\n",j,n+j-1+counter);
        %fflush(stdout);
        r(n+j+counter)=d(i)+p(i)*(j);
        task(n+j+counter)=task(i);
        d(n+j+counter)=d(i)+p(i)*(j+1);
        p(n+j+counter)=p(i);
        x(n+j+counter)=x(i);
        for k = 1:x(i)
            C(n+j+counter, k)=C(i, k);
        end
    end
    counter = counter + (hp/p(i))-1;	%All the -1's are because of first pre entered job!
end

for i = 1:nj
    fprintf("Job %d,Task=%d r = %f  d = %f p = %f x = %d\n",i+1,task(i),r(i),d(i),p(i),x(i));
end

u11=0;
u22=0;
u21=0;

for i = 1:n
    if x(i) == 1
        u11 = u11+ (C(i,1)/(d(i)-r(i)));
    end
    
    if x(i) == 2
        u21 = u21 + (C(i,1)/(d(i)-r(i)));
        u22 = u22 + (C(i,1)/(d(i)-r(i)));
    end
end

%work;

if u11+u22<=1
    work=1;
    fprintf("\nThis Falls in case 1, i.e. U1(1) + U2(2) <=1\n");
elseif (u11+(u21/(1-u22))<=1)
    work=2;
    fprintf("\nThis Falls in case 2, i.e. U1(1) + U2(1)/1-U2(2) <=1\n");

else
    fprintf("Doesnt belong to any case! \n");
    fprintf("\nWith U1(1) = %f, U2(1) = %f, U2(2)=%f\n",u11,u21,u22);
    return;
end
	
fprintf("\nWith U1(1) = %f, U2(1) = %f, U2(2)=%f\n",u11,u21,u22);

%srand(time(0));					//To seed with current time : IMP : Keep outside loop where rand nos. are generated!

jobtemp = zeros(n,1); %++ is added before the term everytime

for i = 1:nj
    jobtemp(task(i)) = jobtemp(task(i))+1;
    fprintf("\n**For Task %d, Job %d\n",task(i),jobtemp(task(i)));
    
    %fflush(stdout);
    for j = 1:x(i)
        
        %float use=(float)rand()/((float)(RAND_MAX/((float)C[i][j])))+0.5*(float)C[i][j];		//So final value lies anywhere from .5C[i][j] to 1.5C[i][j]. Yay.
		
        %Doubt : How to change this range and which range is better and more awesome? 
        
        %float use;

        choice = randi([0,1]);
        use = (rand(1))*(C(i, j) - 0.7*C(i,j))+0.7*C(i,j);	%To gen random nos. between .7 to 1.0 	
		
			
		%	else 
		%	{
				
				
		%		if(choice==0)
		%			use=((float)rand()/(float)(RAND_MAX))*((float)C[i][j]-(float).7*C[i][j])+(float).7*C[i][j];	//To gen random nos. between .7 to 1.0
					
		%		else 
		%			use=((float)rand()/(float)(RAND_MAX))*((float)C[i][1]-(float).7*C[i][1])+(float).7*C[i][1];	//To gen random nos. between .7 to 1.0
				
				
		%	}
			c(i,j)=use;
			fprintf("Level  %d's Realised Value: %f\n",j,c(i,j));
			fprintf("Level  %d's entered WCET  : %f\n",j,C(i,j)); 
		%//	if(choice==1)
		%//	printf("Task %d is executing in Level 2",i+1);
    end
end	
	
fprintf("\n");

%int choose;
	
predict = zeros(nj,1);

for i = 1:nj
    
    %predict(i)=0;
    
    if(x(i)==2)
        choose = randi([0,1]);
        
        if(choose==1)
            predict(i)=1;
            fprintf("**Task %d choosen for Level 2\n",i);
        end
    end
end
	
fprintf("\n\n---------------------Scheduling Started-------------------\n");
if(work==1)	%//1st Case
    %//Apply EDF to normal unmodified deadlines, if system reaches level 2, discard all level 1 jobs and execute only level 2 jobs.
		
    %// Step 1 : Applying EDF
	
    
	done = zeros(nj,1); %bool done[nj];		//notes whether the job of a task is completed or not
    job = zeros(n,1); %int *job=(int*)malloc(n*sizeof(int));	//To denote which job of a task it is
	job(1:nj) = 1;%//Starts with 1st job of every task
    
    min = intmax ('int32');
    %mintask 
    count = 0; 
    level = 1; 
    rmin = intmax ('int32');
    begin = intmax ('int32');
    
    for i = 1:n   %//No need to check further jobs as next jobs are dependent on 1st one
        if (r(i) < begin)
				begin = r(i);
        end
    end
    t=0; %//t is current system time
    while(t<hp+begin)
        
        % 			/*for(int i=0;i<n;i++)
        % 			{
        % 				if(d[i]<min && done[i]==false)
        % 				{
        % 					min=d[i];
        % 					mintask=i;
        % 				}
        % 			}*/
			
        mintask = checknexttask(t,nj,r,d,done);
            
        if(mintask==-1)
            fprintf("!!Execution of all jobs in this HyperPeriod Finished !! \n");
            return;%exit(0);
        end
            
        fprintf("DEBUG: Mintask= %d\n",mintask);
        if(r(mintask)>t)
            t=r(mintask);
        end
			
        fprintf("Executing Task %d, Job = %d at t= %f (Arrival = %f)\n",task(mintask),job(task(mintask)),t,r(mintask));
				
        if(c(mintask, predict(mintask))>C(mintask,1)&& checknexttask(t+C(mintask,1),nj,r,d,done)==mintask)


            fprintf("System's Criticality Level Changed to 2 because of Task =%d,Job %d",task(mintask),job(task(mintask)));

            t = t+C(mintask,1);
            fprintf(" at time t =%f\n",t);

            c(mintask,2)=c(mintask,2)-C(mintask,1);


            level=2;

        else
            if(checknexttask(t+c(mintask,1),nj,r,d,done)==mintask)
                
                fprintf("Finished Executing Task %d, Job  %d at t= %f (Deadline = %f) \n",task(mintask),job(task(mintask)),t+c(mintask,1),r(mintask)+p(mintask));
                t=t+c(mintask,1);
                job(task(mintask))=job(task(mintask))+1;
                done(mintask)=true;
                count=count+1;

            else
                rmin = intmax ('int32');dmin = intmax ('int32');%newtask;

                for i = 1:nj
                    if(r(i)>t && d(i) < d(mintask) && done(i)==false && d(i)<dmin && r(i)<=rmin)
                        if(r(i)==rmin)
                            if(d(i)<dmin)
                                dmin=d(i);
                                newtask=i;
                            end	
                        else
                            rmin=r(i);
                            dmin=d(i);
                            newtask=i;	
                        end			
                    end
                end
                fprintf("Preempted In Middle at t = %f \n",r(newtask));


                c(mintask,1)=c(mintask,1)-(r(newtask)-t);
                t=r(newtask);

                rmin = intmax ('int32');
                dmin = intmax ('int32');
            end
        end
        
        min = intmax ('int32');
    end
		
		if(count==nj)
			fprintf("All tasks completed their execution successfully\n");
        elseif(level==2)
			fprintf("\n!!Criticality Level 2 Entered, tasks of criticality level 1 dropped\n\n");
			
			%//Step 2: Execute Tasks of Criticality Level 2 in EDF Mode
            %//Doubt :: What if the task in criticality level 2 also exceeds its WCET ??
            
            while(count~=n)
				for i = 1:n
					if(d(i)<min && done(i)==false && x(i)==2)
						min=d(i);
						mintask=i;
                    end
                end
                
                done(mintask)=true;
				
				if(r(mintask)>t)
                    t=r(mintask);
                end
				fprintf("Task %d executed from t = %f (Arrival = %f)\n",mintask+1,t,r(mintask));
				
				fprintf("Finished  task %d at %f (In Criticality Level 2, Deadline = %f)\n",mintask+1,t+c(mintask,2),r(mintask)+p(mintask));
				t = t+c(mintask,2);
				
				count = count+1;
				min = intmax ('int32'); 			
				 
            end
			
        
        else
            fprintf("Error in program!!");
        end
elseif (work==2)
    fprintf("\t\tCase II \n");
    
    lambda=(u21)/(1-u11);
    
    fprintf("Task\tFinal Deadline\n");
    for i = 1:n
        if(x(i)==2)
            d(i)=r(i)+p(i)*lambda;
        end
        fprintf("%d\t%f\n",i,d(i));
    end
    %//Apply EDF to New Deadlines, if system reaches level 2, discard all level 1 jobs amd execute only level 2 jobs with normal unmodified deadlines.
		
	%// Step 1 : Applying EDF to new deadlines
    done = zeros(n,1);		%//notes whether a task is completed or not
    
    min = intmax ('int32');
    %mintask
    count=0;
    level=1;
    
    t=0; %//t is current system time
    while(count~=n && level==1)
        for i = 1:n
            if(d(i)<min && done(i)==false)
                min = d(i); 
                mintask=i;
            end
        end
        
        if(r(mintask)>t)
			t=r(mintask);
        end
        
        if(c(mintask,predict(mintask))>C(mintask, 1))
            fprintf("Executing Task %d at t= %f Arrival=(%f)\n",mintask,t,r(mintask));
            fprintf("System's Criticality Level Changed to 2 because of task %d",mintask);
            t = t+C(mintask,1);
            fprintf(" at time t =%f\n",t);
            
            c(mintask,2) = c(mintask,2)- C(mintask,1);
            
            level=2;
				
			
        else
            fprintf("Executing Task %d at t= %f (Arrival = %f)\n",mintask,t,r(mintask));
            
            if(checknexttask(t+c(mintask,1),n,r,d,done)==mintask)
                fprintf("Finished Executing Task %d at t= %f (Deadline = %f) \n",mintask,t+c(mintask,1),r(mintask)+p(mintask));
                t= t+c(mintask,1);
                done(mintask)=true;
                count = count+1;
            else
                rmin = intmax ('int32');
                dmin = intmax ('int32');
                %newtask;
                
                for i = 1:n
                    if(r(i)>t && d(i) < d(mintask) && done(i)==false && d(i)<dmin && r(i)<=rmin)
                        if(r(i)==rmin)
                            if(d(i)<dmin)
                                dmin=d(i);
                                newtask=i;
                            end							
                        else
                            rmin = r(i);
                            dmin = d(i);
                            newtask=i;	
                        end			
                    end						
								
                end
                fprintf("Preempted In Middle at t = %f \n",r(newtask));
                
                c(mintask, 1)=c(mintask,1)-(r(newtask)-t);
                t=r(newtask);
                
                rmin = intmax ('int32');
                dmin = intmax ('int32');
            end
        end
        
        min = intmax ('int32');
    end
    
    if(count==n)
        fprintf("All tasks completed their execution successfully\n");
    elseif(level==2)
        fprintf("\n!!Criticality Level 2 Entered, tasks of criticality level 1 dropped.\nDeadline of all Level 2 Tasks modified back to Original Level \n\n");
        
        %//Step 2: Execute Tasks of Criticality Level 2 in EDF Mode with unmodified deadlines
        
        fprintf("RemTask\tFinal Deadline\n");
        
        for i = 1:n
            if(x(i)==2 && done(i)==false)
                d(i)=r(i)+p(i);
                
				fprintf("%d\t%f\n",i,d(i)); 
            end
        end
        
        while(count~=n)
            for i = 1:n
                if(d(i)<min && done(i)==false && x(i)==2)
                    min=d(i);
                    mintask=i;
                end
            end
            
            done(mintask)=true;
            
            if(r(mintask)>t)
                t=r(mintask);
            end
            
            fprintf("Task %d executed from t = %f (Arrival = %f)\n",mintask,t,r(mintask));
            
            fprintf("Finished  task %d at %f (In Criticality Level 2, Deadline = %f)\n",mintask,t+c(mintask,2),r(mintask)+p(mintask));
            t=t+c(mintask,2);
            
            count=count+1;
            min = intmax ('int32');
        end
        
    else
        fprintf("Error in program!!");
    end	
end