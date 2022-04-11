classdef DragPoint
    %DRAGPOINT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        X, Y, OldX, OldY, PosBeforeDrag
    end
    
    methods
        function obj = DragPoint(x, y, ax, f, OnDragged)
            obj.X = x;
            obj.Y = y;            
            obj.OldX = x;
            obj.OldY = y;            
            obj.ax = ax;
            obj.ax.Toolbar.Visible = 'off';            
            obj.f = f;            
            obj.point_handle = -1;
            obj.mouse_is_over = false;
            obj.is_dragged = false;
            obj.drag_delta = [];
            obj.OnDragged = OnDragged;
            
            obj.PosBeforeDrag = [];
            
            obj.COLOR_MOUSE_OUT = [0, 1, 1];
            obj.COLOR_MOUSE_OVER = [0, 0, 0];
            obj.COLOR_MOUSE_DOWN = [0, 0, 0];
            
            obj.M_MOUSE_OUT = 'o';
            obj.M_MOUSE_OVER = 'o';
            obj.M_MOUSE_DOWN = 's';
        end
        
        function obj = Draw(obj, x, y)
            axes(obj.ax);
            obj.X = x;
            obj.Y = y;
            obj.point_handle = plot(x, y, 'MarkerSize', 10);
            obj.point_handle.Color = obj.COLOR_MOUSE_OUT;
            obj.point_handle.Marker = obj.M_MOUSE_OUT;
        end
        
        function b = IsDragged(obj)
           b = obj.is_dragged;
        end
        
        function obj = SetPos(obj, x, y)
           obj.X = x;
           obj.Y = y; 
        end
        
        function obj = OnMouseMove(obj)
            if ~ishandle(obj.point_handle), return; end
            
            mx = obj.f.CurrentPoint(1);
            my = obj.f.CurrentPoint(2);
    
            obj.ax.Units = 'Pixels';
            ax_left =   obj.ax.Position(1);
            ax_right =  ax_left + obj.ax.Position(3);
            ax_bottom = obj.ax.Position(2);
            ax_top =    ax_bottom + obj.ax.Position(4);
    
            if ax_left <= mx && mx <= ax_right && ax_bottom <= my && my <= ax_top
                % mouse is inside the axes
            else
                return;
            end
    
            pos = get(obj.ax, 'CurrentPoint');
            mx = pos(1, 1);
            my = pos(1, 2);
    
            if obj.is_dragged
                obj.X = mx - obj.drag_delta(1);
                obj.Y = my - obj.drag_delta(2);
                obj.point_handle.XData = obj.X;
                obj.point_handle.YData = obj.Y;
                return;
            end
            
            dx = 0.1 * (obj.ax.XLim(2) - obj.ax.XLim(1));
            dy = 0.1 * (obj.ax.YLim(2) - obj.ax.YLim(1));
    
            px = obj.point_handle.XData(1);
            py = obj.point_handle.YData(1);
            
            if mx-dx <= px && px <= mx+dx && my-dy <= py && py <= my+dy
                obj.mouse_is_over = true;
                obj.point_handle.Color = obj.COLOR_MOUSE_OVER;
                obj.point_handle.Marker = obj.M_MOUSE_OVER;
            else
                obj.mouse_is_over = false;
                obj.point_handle.Color = obj.COLOR_MOUSE_OUT;
            end
        end
        
        function obj = UpdateOldPos(obj)
           obj.OldX = obj.X;
           obj.OldY = obj.Y; 
        end
        
        function obj = MoveToPos(obj)
            obj.point_handle.XData = obj.X;
            obj.point_handle.YData = obj.Y;
        end
        
        function obj = OnMouseDown(obj)
            if ~ishandle(obj.point_handle), return; end
            if ~obj.mouse_is_over, return; end
                
            obj.is_dragged = true;
            obj.point_handle.Color = obj.COLOR_MOUSE_DOWN;
            obj.point_handle.Marker = obj.M_MOUSE_DOWN;
            obj.drag_delta = obj.ax.CurrentPoint(1, 1 : 2)' - [obj.X; obj.Y];
            
            obj.PosBeforeDrag = [obj.X; obj.Y];
        end
        
        function obj = OnMouseUp(obj)
            if ~ishandle(obj.point_handle), return; end
            if ~obj.mouse_is_over, return; end
            
            obj.is_dragged = false;
            obj.point_handle.Color = obj.COLOR_MOUSE_OVER;
            obj.point_handle.Marker = obj.M_MOUSE_OVER;
            obj.drag_delta = [];
            
            obj.point_handle.XData = obj.X;
            obj.point_handle.YData = obj.Y;
            
            obj.PosBeforeDrag = [];
        end
    end
    
    properties (Access = private)
        ax, f, point_handle, 
        mouse_is_over, is_dragged, 
        drag_delta,
        OnDragged,
        COLOR_MOUSE_OUT, COLOR_MOUSE_OVER, COLOR_MOUSE_DOWN,
        M_MOUSE_OUT, M_MOUSE_OVER, M_MOUSE_DOWN
    end
    
    methods (Access = private)
        
    end
end

