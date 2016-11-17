function [  ] = plotfun( fn, varargin)
% Plot functions on a graph that can be panned and zoomed continuously

if nargin == 2
    default_limits = varargin{1};
else
    default_limits = [-1 1 -1 1]*5;
end
drawFun(default_limits);

hp = pan;
set(hp,'ActionPostCallback',@updatePan);
set(hp,'Enable','on');

hz = zoom;
set(hz,'ActionPostCallback',@postZoom);
last_limits = default_limits;

    function updatePan(obj,evd)
        newLim = [get(evd.Axes,'XLim') get(evd.Axes,'YLim')];
        drawFun(newLim)
    end

    function drawFun(limits)
        fplot(gca,fn,limits);
        grid on
    end

    function postZoom(obj,evd)
        dir = get(zoom(obj),'direction');
        if strcmp(dir,'out')
            drawFun(last_limits.*2);
        end
        last_limits = [get(evd.Axes,'XLim') get(evd.Axes,'YLim')];
    end
end