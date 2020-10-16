function LINEARSTATIC(nodes, elements, loads, boundaries)
  NDOF = 2;
  tot_nodes = length(nodes);
  dim_problem = NDOF * tot_nodes;
  u = zeros(dim_problem, 1);
  %f = zeros(dim_problem, 1);
  %K = zeros(dim_problem, dim_problem);
  nodeIDs = nodesPosition(tot_nodes, nodes);
  %STEP 1: stiffness assembly
  K = assembly(nodes, nodeIDs, elements, dim_problem);
  %STEP 2: boundaries definition
  [u, fix] = apply_boundaries(u, boundaries, nodeIDs, dim_problem);
  %STEP 3: loads assembly
  f = loads_assembly(loads, K, u, nodeIDs, dim_problem);
  %STEP 4: solver linear system
  u = solver(K, u, f, fix, dim_problem);
  %---
  node_u = zeros(NDOF, 1);
  for n = 1:tot_nodes
    pos = findNodePosition(nodes(n).ID, nodeIDs);
    for i = 1:NDOF
      node_u(i) = u(NDOF * (pos -1) + i);
    end
    nodes(n).update(node_u);
  end
end
%--------------------------------------------------------------------------
function [nodeIDs] = nodesPosition(tot_nodes, nodes)
  nodeIDs = zeros(tot_nodes, 1);
  for n = 1: tot_nodes
    nodeIDs(n) = nodes(n).ID;
  end
end
%--------------------------------------------------------------------------
function [pos] = findNodePosition(ID, nodeIDs)
  tot = length(nodeIDs);
  pos = 0;
  if ((ID < tot) && (ID == nodeIDs(ID)))
    pos = ID;
  else
    for n = 1:tot
      if (ID == nodeIDs(n))
        pos = n;
        break
      end
    end
  end
end
%--------------------------------------------------------------------------
function [u, fix] = apply_boundaries(u, boundaries, nodeIDs, dim_problem)
  NDOF = 2;
  fix = zeros(dim_problem, 1);
  dim = length(boundaries);
  for b = 1:dim
    ID = boundaries(b).nodeID;
    pos = findNodePosition(ID, nodeIDs);
    for i = 1:NDOF
      fix(NDOF * (pos -1) + i) = boundaries(b).fix(i);
      u(NDOF * (pos -1) + i) = boundaries(b).disp(i);
    end
  end
end
%--------------------------------------------------------------------------
function [K] = assembly(nodes, nodeIDs, elements, dim_problem)
  K = zeros(dim_problem, dim_problem);
  tot_elem = length(elements);
  NDOF = 2;
  TOTELNODES = 2;
  for e = 1:tot_elem
    elK = elements(e).stiffness();
    for nodeRow = 1:TOTELNODES
      posRow = findNodePosition(elements(e).nID(nodeRow), nodeIDs);
      for nodeCol = 1:TOTELNODES
        posCol = findNodePosition(elements(e).nID(nodeCol), nodeIDs);
        for i = 1:NDOF
          row = NDOF * (posRow - 1) + i;
          rowEl = NDOF * (nodeRow - 1) + i;
          for j = 1:NDOF
            col = NDOF * (posCol - 1) + j;
            colEl = NDOF * (nodeCol - 1) + j;
            K(row, col) = K(row, col) + elK(rowEl, colEl);
          end
        end
      end
    end
  end
end
%--------------------------------------------------------------------------
function [f] = loads_assembly(loads, K, u, nodeIDs, dim_problem)
  f = zeros(dim_problem, 1);
  NDOF = 2;
  dim_loads = length(loads);
  %STEP 1: apply loads
  for l = 1:dim_loads
    pos = findNodePosition(loads(l).nodeID, nodeIDs);
    for i = 1:NDOF
      f(NDOF * (pos - 1) + i) = f(NDOF * (pos - 1) + i) + loads(l).f(i);
    end
  end
  %STEP 2: K*u
  for i = 1:dim_problem
    for j = 1:dim_problem
      f(i) = f(i) - K(i, j) * u(j);
    end
  end
end
%--------------------------------------------------------------------------
function [u] = solver(K, u, f, fix, dim_problem)
  bcCont = 0;
  for i = 1:dim_problem
    if (fix(i) == 1)
      index = i - bcCont;
      K(:, index) = [];
      K(index, :) = [];
      f(index) = [];
      bcCont = bcCont + 1;
    end
  end
  if (bcCont < dim_problem)
    x = K\f;
    cont = 1;
    for i = 1:dim_problem
      if (fix(i) == 0)
        u(i) = x(cont);
        cont = cont + 1;
      end
    end
  end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------