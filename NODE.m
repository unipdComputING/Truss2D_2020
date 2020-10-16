classdef NODE < handle
  %------------------------------------------------------------------------
  properties
    ID;
    x = [];
    u = [];
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this = NODE(index, X)
      this.ID = index;
      this.x = X;
      this.u = zeros(2, 1);
    end
    %----------------------------------------------------------------------
    function d = distance(this, node)
      d = sqrt((node.x(1) - this.x(1))^2 + (node.x(2) - this.x(2))^2);
    end
    %----------------------------------------------------------------------
    function alpha = angle(this, node)
      a = node.x(1) - this.x(1);
      b = node.x(2) - this.x(2);
      alpha = pi / 2;
      if (a ~= 0.0)
        alpha = atan(b / a);
      end
    end
    %----------------------------------------------------------------------
    function write(this)
      fprintf('++ Node ID: %i\n', this.ID);
      fprintf('   x: [%f; %f];\n', this.x(1), this.x(2));
      fprintf('   u: [%f; %f];\n', this.u(1), this.u(2));
      fprintf('++\n')
    end
    %----------------------------------------------------------------------
    function draw(this, Fig_ID)
      figure(Fig_ID)
      hold on
      plot(this.x(1), this.x(2), 'go');
      hold off
    end
    %----------------------------------------------------------------------
    function update(this, u)
      this.u = u;
    end
    %----------------------------------------------------------------------
  end
  %------------------------------------------------------------------------
end