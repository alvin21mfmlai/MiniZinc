
% define variables %
int: totalNodes; % Number of nodes
int: weightedEdges; % Number of weighted edges 
int: INF = 9999; % Arbitrary large number
1..totalNodes: Start; % Start node
1..totalNodes: End; % End node

% define data structures %
set of int: Edges = 1..weightedEdges; %  The actual edges
array[Edges] of int: lengthEdge; % Array of edge lengths
array[Edges] of 1..totalNodes: edgeStart; % Array of starting nodes
array[Edges] of 1..totalNodes: edgeEnd; % Array of ending nodes
array[Edges] of var 0..1: x; % Array of variables indicating if edge is used

% define constraint %
constraint
    forall( i in 1..totalNodes ) (
        % outgoing flow - % incoming flow
        if i = Start then sum(e in Edges where edgeStart[e] = i)(x[e]) - sum(e in Edges where edgeEnd[e] = i)(x[e]) = 1
        elseif i = End then sum(e in Edges where edgeStart[e] = i)(x[e]) - sum(e in Edges where edgeEnd[e] = i)(x[e]) = -1
        else sum(e in Edges where edgeStart[e] = i)(x[e]) - sum(e in Edges where edgeEnd[e] = i)(x[e]) = 0
        endif
    );

% optimization function %
solve minimize sum(e in Edges)( lengthEdge[e] * x[e] );

output ["Length: ", show(sum(e in Edges)(lengthEdge[e] * x[e])), "\n"] ++
       ["Start : ", show(Start), "\n"] ++
       ["End   : ", show(End), "\n\n"] ++
       ["Edges in shortest path:\n"] ++
       [ if   fix(x[e]) = 1
         then show(edgeStart[e]) ++ " -> " ++ show(edgeEnd[e]) ++ "\n" 
         else "" 
         endif | e in Edges
       ];

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

% simple case of 5 nodes
% N = 5;
% M = 10;
% Edge_Start = [1, 1, 1, 1, 2, 2, 2, 3, 3, 4]; -> total of 10 
% Edge_End = [2, 3, 4, 5, 3, 4, 5, 4, 5, 5];  -> total of 10 
% L = [1, 1, INF, 1, 1, 1, 1, 1, 1, 1]; -> total of 10 
% Start = 1;
% End = 5;