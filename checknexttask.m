function res = checknexttask(t, n, r, d, done)
    mintask = -1;
    flagprev = false;
	
	for i = 1:n
        if(r(i)<t && done(i)==false)
            flagprev = true;
        end
    end
    
    if(flagprev==false)
        rmin = intmax ('int32');
        dmin = intmax ('int32');
        
        for i = 1:n
            if(r(i)<=rmin && done(i)==false)
                if(r(i)==rmin)
                    if(d(i)<dmin)
						dmin = d(i);
						mintask = i;
                    end
                else
                    rmin = r(i);
					dmin = d(i);
					mintask = i;	
                end				
            end
        end
    else
        rmin = intmax ('int32');
        dmin = intmax ('int32');
		
		for i = 1:n
            if(r(i)<=t && d(i)<dmin && done(i)==false)
                mintask = i;
				dmin = d(i);
            end
        end
    end
    
    res = mintask;
end