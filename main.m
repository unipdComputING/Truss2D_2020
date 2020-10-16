close all; clc; clf;
%--------------------------------------------------------------------------
FIG_ID = 1;
%--------------------------------------------------------------------------
nodes = [NODE(1, [0; 0]);
         NODE(3, [50; 50]);
         NODE(2, [100; 0])];

elements = [ELEMENT(1, nodes(1), nodes(2), 333.0, 200000.0);
            ELEMENT(2, nodes(2), nodes(3), 333.0, 200000.0)];
          
loads = [LOAD(1, 3, [0; -100.0]);];

boundaries = [BOUNDARY(1, [1; 1], [0.0; 0.0]);
              BOUNDARY(2, [1; 1], [0.0; 0.0])];
%---
LINEARSTATIC(nodes, elements, loads, boundaries);
%---

for n = 1:length(nodes)
  nodes(n).write();
  nodes(n).draw(FIG_ID);
end

for e = 1:length(elements)
  elements(e).write();
  elements(e).draw(FIG_ID, nodes);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------