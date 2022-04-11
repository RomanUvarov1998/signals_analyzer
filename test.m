f = figure(4); cla; hold on; grid on;

tiledlayout(2, 1);

nexttile; cla; hold on; grid on;
plot(1:10,1:10,'-o','buttondownfcn',{@Mouse_Callback,'down'});

nexttile; cla; hold on; grid on;
plot(1 : 10, 2 : 11, 'b');
p = plot(5, 3, '-or');
f.WindowButtonMotionFcn = {@plot_mouse_moution, p, f};

global dragged_point ax
dragged_point = [];
ax = gca;
ax.Toolbar.Visible = 'off';

function plot_mouse_moution(s, e, point, f)
    global dragged_point ax
    
    m_x = f.CurrentPoint(1);
    m_y = f.CurrentPoint(2);
    
    ax.Units = 'Pixels';
    ax_left = ax.Position(1);
    ax_right = ax_left + ax.Position(3);
    ax_bottom = ax.Position(2);
    ax_top = ax_bottom + ax.Position(4);
    
    if ax_left <= m_x && m_x <= ax_right && ax_bottom <= m_y && m_y <= ax_top
        % ok
    else
        return;
    end
    
    pos = get(ax,'CurrentPoint');
    
    mouse_x = pos(1, 1);
    mouse_y = pos(1, 2);
    
    if ~isequal(dragged_point, [])
        point.XData = mouse_x;
        point.YData = mouse_y;
        return;
    end
    
    sx = 0.1 * (ax.XLim(2) - ax.XLim(1));
    sy = 0.1 * (ax.YLim(2) - ax.YLim(1));
    dx = mouse_x - point.XData(1);
    dy = mouse_y - point.YData(1);
    
    dist = sqrt( dx^2 * sy^2 + dy^2 * sx^2 );
    min_dist = sx^2 * sy^2;
    
    if dist < min_dist
        point.Color = [0, 0, 1];
        ax.XLimMode
        f.WindowButtonDownFcn = {@on_point_btn_down, point};
        f.WindowButtonUpFcn = {@on_point_btn_up, point};
    else
        point.Color = [1, 0, 0];
        f.WindowButtonDownFcn = [];
        f.WindowButtonUpFcn = [];
    end
end

function on_point_btn_down(~, ~, p)
    global dragged_point
    p.Color = [0, 1, 1];
    dragged_point = p;
end

function on_point_btn_up(~, ~, p)
    global dragged_point
    p.Color = [1, 0, 0];
    dragged_point = [];
end

% Callback function for each point
function Mouse_Callback(hObj,~,action)
    persistent curobj xdata ydata ind
    pos = get(gca,'CurrentPoint');
    
    mouse_x = pos(1, 1);
    mouse_y = pos(1, 2);
    
    switch action
      case 'down'
          curobj = hObj;
          xdata = get(hObj,'xdata');
          ydata = get(hObj,'ydata');
          [~,ind] = min( sum( (xdata - mouse_x) .^ 2 + (ydata - mouse_y) .^ 2, 1) );
          set(gcf,...
              'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
              'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
          
      case 'move'
          % vertical move
          xdata(ind) = mouse_x;
          ydata(ind) = mouse_y;
          set(curobj, 'xdata', xdata);
          set(curobj, 'ydata', ydata);
          
      case 'up'
          set(gcf,...
              'WindowButtonMotionFcn',  '',...
              'WindowButtonUpFcn',      '');
    end
end