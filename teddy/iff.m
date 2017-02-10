function [ result ] = iff( cond, t, f )
% Inline iff function returns t if cond is true, f otherwise
    if cond
        result = t;
    else
        result = f;
    end

end

