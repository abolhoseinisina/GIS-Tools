function [x,y] = line_intersection(l1,l2)
    [x1,y1,m1] = getSlope(l1);
    [x2,y2,m2] = getSlope(l2);
    
    if (~isnan(m1)) && (~isnan(m2)) && (m1 ~= m2)
        x = ((m1*x1-m2*x2)-(y1-y2))/(m1-m2);
        y = y1+m1*(x-x1); 
    elseif isnan(m1) && (~isnan(m2))
        x = x1;
        y = y2+m2*(x-x2);
    elseif ~isnan(m1) && isnan(m2)
        x = x2;
        y = y1+m1*(x-x1);
    else
        x = Inf;
        y = Inf;
    end
end    
    
function [x1,y1,m] = getSlope(l)
    m = (l(4)-l(2))/(l(3)-l(1));
    if abs(m) == Inf
        x1 = l(1);
        y1 = 0;
        m = NaN;
    else
        x1 = l(1);
        y1 = l(2);
    end
end
    
