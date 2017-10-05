function [ok,list1,list2]=disunion(A,B)

    % init
    ok = true;
    list1 = {};
    list2 = {};
     
    % extra items in A?
    idx = ~ismember(A,B);
    if any(idx)
        ok = false;
        list1 = A(idx);
    end
   
    % extra items in B?
    idx = ~ismember(B,A);
    if any(idx)
        ok = false;
        list2 = B(idx);
    end

end