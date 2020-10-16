classdef ELEMENT < handle
  %------------------------------------------------------------------------
  properties
    ID;
    nID = [];
    young;
    area;
    l0;
    alpha;
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this = ELEMENT(index, n1, n2, A, E)
      this.ID = index;
      this.young = E;
      this.area = A;
      this.nID = [n1.ID; n2.ID];
      this.l0 = n1.distance(n2);
      this.alpha = n1.angle(n2);
      
      if (this.l0 == 0.0)
        fprintf('WARNING: Elem: %i with l0 = 0\n', this.ID);
      end
      
    end
    %----------------------------------------------------------------------
    function k = locstiffness(this)
      k = zeros(4, 4);
      k(1, 1) =  1.0;
      k(1, 3) = -1.0;
      k(3, 1) = -1.0;
      k(3, 3) =  1.0;
      k = (this.young * this.area / this.l0) * k;
    end
    %----------------------------------------------------------------------
    function R = rotMat(this)
      c = cos(this.alpha);
      s = sin(this.alpha);
      r = [ c, s;
           -s, c;];
      z = [0.0, 0.0;
           0.0, 0.0;];
      R = [r, z;
           z, r];
    end
    %----------------------------------------------------------------------
    function k = stiffness(this)
      k = this.locstiffness();
      R = this.rotMat();
      k = R' * k;
      k = k * R;
    end
    %----------------------------------------------------------------------
    function write(this)
      fprintf('++ Element ID: %i\n', this.ID);
      fprintf('   nodes ID: [%i; %i];\n', this.nID(1), this.nID(2));
      fprintf('   l0   : %f;\n', this.l0);
      fprintf('   area : %f;\n', this.area);
      fprintf('   alpha: %f;\n', this.alpha);
      fprintf('   young: %f;\n', this.young);
      fprintf('++\n')
    end
    %----------------------------------------------------------------------
    function draw(this, Fig_ID, nodes)
      pos1 = 0;
      pos2 = 0;
      n1_ID = this.nID(1);
      n2_ID = this.nID(2);
      
      dim_nodes = length(nodes);
      
      if ((n1_ID <= dim_nodes) && (n1_ID == nodes(n1_ID).ID))
        pos1 = n1_ID;
      else
        for n = 1: dim_nodes
          if (n1_ID == nodes(n).ID)
            pos1 = n;
            break
          end
        end
      end
      
      if ((n2_ID <= dim_nodes) && (n2_ID == nodes(n2_ID).ID))
        pos2 = n2_ID;
      else
        for n = 1: dim_nodes
          if (n2_ID == nodes(n).ID)
            pos2 = n;
            break
          end
        end
      end
      
      if ((pos1 ~= 0) && (pos2 ~= 0))
        X = [nodes(pos1).x(1); nodes(pos2).x(1)];
        Y = [nodes(pos1).x(2); nodes(pos2).x(2)];
        figure(Fig_ID)
        hold on
        plot(X, Y, 'k-');
        hold off
      end
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
  end
  %------------------------------------------------------------------------
end