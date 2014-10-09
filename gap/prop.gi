#############################################################################
##
#W  props.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

if IsBound(IS_STRONGLY_CONNECTED_DIGRAPH) then
  InstallMethod(IsStronglyConnectedDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    return IS_STRONGLY_CONNECTED_DIGRAPH(Adjacencies(graph));
  end);
else
  InstallMethod(IsStronglyConnectedDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    local adj, n, stack1, len1, stack2, len2, id, count, fptr, level, l, w, v;

    adj := Adjacencies(graph);
    n := Length(adj);

    if n = 0 then
      return true;
    fi;

    stack1 := EmptyPlist(n); len1 := 1;
    stack2 := EmptyPlist(n); len2 := 1;
    id:=[ 1 .. n ] * 0;
    level := 1;
    fptr := [];

    fptr[1] := 1; # vertex
    fptr[2] := 1; # adjacency index
    stack1[len1] := 1;
    stack2[len2] := len1;
    id[1] := len1;

    while true do # we always return before level = 0
      if fptr[2 * level] > Length(adj[fptr[2 * level - 1]]) then
        if stack2[len2] = id[fptr[2 * level - 1]] then
          repeat
            n := n - 1;
            w := stack1[len1];
            len1 := len1 - 1;
          until w = fptr[2 * level - 1];
          return (n = 0);
        fi;
        level := level - 1;
      else
        w := adj[fptr[2 * level - 1]][fptr[2 * level]];
        fptr[2 * level] := fptr[2 * level] + 1;

        if id[ w ] = 0 then
          level := level + 1;
          fptr[2 * level - 1] := w; #fptr[0], vertex
          fptr[2 * level ] := 1;   #fptr[2], index
          len1 := len1 + 1;
          stack1[ len1 ] := w;
          len2 := len2 + 1;
          stack2[ len2 ] := len1;
          id[ w ] := len1;
        else # we saw <w> earlier in this run
          while stack2[ len2 ] > id[ w ] do
            len2 := len2 - 1; # pop from stack2
          od;
        fi;
      fi;
    od;
  end);
fi;

if IsBound(IS_ACYCLIC_DIGRAPH) then
  InstallMethod(IsAcyclicDigraph, "for a digraph",
  [IsDigraph], function(graph)
    return IS_ACYCLIC_DIGRAPH(Adjacencies(graph));
  end);
else
  InstallMethod(IsAcyclicDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    local adj, nr, verts, vertex_complete, vertex_in_path, stack, level, j, 
    k, i;

    adj := Adjacencies(graph);
    nr := NrVertices(graph);
    verts := Vertices(graph);
    vertex_complete := BlistList( verts, [ ] );
    vertex_in_path := BlistList( verts, [ ] );
    stack:=EmptyPlist(2 * nr + 2);

    for i in verts do
      if Length(adj[i]) = 0 then
        vertex_complete[i] := true;
      elif not vertex_complete[i] then
        level := 1;
        stack[1] := i;
        stack[2] := 1;
        while true do
          j:=stack[2 * level - 1];
          k:=stack[2 * level];
          if vertex_in_path[j] then
            return false;  # We have just travelled around a cycle
          fi;
          # Check whether:
          # 1. We've previously finished with this vertex, OR
          # 2. Whether we've investigated all branches descending from it
          if vertex_complete[j] or k > Length(adj[j]) then
            vertex_complete[j] := true;
            level := level - 1 ;
            if level = 0 then
              break;
            fi;
            # Backtrack and choose next available branch
            stack[2 * level]:=stack[2 * level] + 1;
            vertex_in_path[stack[2 * level - 1]] := false;
          else # Otherwise move onto the next available branch
            vertex_in_path[j] := true;
            level := level + 1;
            stack[2 * level - 1] := adj[j][k];
            stack[2 * level] := 1;
          fi;
        od;
      fi;
    od;
    return true;
  end);
fi;

# simple means no multiple edges (loops are allowed)
if IsBound(IS_SIMPLE_DIGRAPH) then
  InstallMethod(IsSimpleDigraph, "for a digraph",
  [IsDigraph], IS_SIMPLE_DIGRAPH);
else
  InstallMethod(IsSimpleDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    local adj, nr, range, source, len, n, current, marked, x, i;

    if not HasRange(graph) then
      # Currently this is never entered: if we don't have range, graph was
      # created by adjacencies, so IsSimpleDigraph was set true at creation
      return true;
    elif HasAdjacencies(graph) then
      adj := Adjacencies(graph);
      nr := 0;
      for x in adj do
        nr := nr + Length(x);
      od;
      return nr = Length(Range(graph));
    else
      range := Range(graph);
      source := Source(graph);
      len := Length(range);
      n := NrVertices(graph);
      current := 0;
      marked := [ 1 .. n ] * 0;

      for i in [ 1 .. len ] do
        if source[i] <> current then
          current := source[i];
          marked[range[i]] := current;
        elif marked[range[i]] = current then
          return false;
        else
          marked[range[i]] := current;
        fi;
      od;
      return true;
    fi;

  end);
fi;

# Complexity O(number of edges)
# this could probably be improved further ! JDM

InstallMethod(IsSymmetricDigraph, "for a digraph",
[IsDigraph],
function(graph)
  local old, rev, new, i, j;
  
  old := Adjacencies(graph);
  rev := EmptyPlist(Length(old));
  for i in Vertices(graph) do 
    rev[i] := [];
  od;
  
  if ForAll(old, IsSSortedList) then 
    for i in Vertices(graph) do
      for j in old[i] do 
        rev[j][LEN_LIST(rev[j])+1]:=i;
      od;
    od;
    return rev = old;
  else
    new := EmptyPlist(Length(old));
    for i in Vertices(graph) do
      new[i]:=AsSSortedList(ShallowCopy(old[i]));
      for j in new[i] do 
        rev[j][LEN_LIST(rev[j])+1]:=i;
      od;
    od;
    return rev = new;
  fi;
end);

# Functional means: for every vertex v there is exactly one edge with source v

InstallMethod(IsFunctionalDigraph, "for a digraph by adjacency",
[IsDigraphByAdjacency],
function(graph)
  return ForAll(Adjacencies(graph), x -> Length(x) = 1);
end);

InstallMethod(IsFunctionalDigraph, "for a digraph",
[IsDigraphBySourceAndRange],
function(graph)
  return Source(graph) = Vertices(graph);
end);

#

InstallMethod(IsTournament, "for a digraph",
[IsDigraph], 
function(graph)
  local n;
  
  if not IsSimpleDigraph(graph) then 
    return false;
  fi;

  n := NrVertices(graph);

  if NrEdges(graph) <> n * (n - 1) / 2 then 
    return false;
  fi;
 
  if HasIsAcyclicDigraph(graph) and IsAcyclicDigraph(graph) then 
    return true;
  fi;

  Error("not yet implemented,"); 

end);

#

InstallMethod(IsEmptyDigraph, "for a digraph by source and range",
[IsDigraphBySourceAndRange],
function(digraph)
  return Source(digraph) = [];
end);

#

InstallMethod(IsEmptyDigraph, "for a digraph by adjacencies",
[IsDigraphByAdjacency],
function(digraph)
  local adj, i;

  adj := Adjacencies(digraph);
  for i in adj do
    if i <> [ ] then
      return false;
    fi;
  od;
  return true;
end);

#

InstallMethod(IsEmptyDigraph, "for a digraph with known number of edges",
[IsDigraph and HasNrEdges], 3,
function(digraph)
  return NrEdges(digraph) = 0;
end);

#

InstallMethod(IsReflexiveDigraph, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix], 3,
function(digraph)
  local verts, mat, i;
  
  verts := Vertices(digraph);
  mat := AdjacencyMatrix(digraph);

  for i in verts do
    if mat[i][i] = 0 then
      return false;
    fi;
  od;
  return true;
end);

#

InstallMethod(IsReflexiveDigraph, "for a digraph with adjacencies",
[IsDigraph and HasAdjacencies],
function(digraph)
  local adj;
  
  adj := Adjacencies(digraph);
  return ForAll( Vertices(digraph), x -> x in adj[x] );
end);

#

InstallMethod(IsReflexiveDigraph, "for a digraph (with only source and range)",
[IsDigraph],
function(digraph)
  local source, range, id, lastloop, current, i;
  
  source := Source(digraph);
  range := Range(digraph);
  id := BlistList(Vertices(digraph), []);
  lastloop := 0;
  current := 1;

  for i in [ 1 .. Length(source) ] do
    if source[i] <> current then
      current := current + 1;
      if source[i] > lastloop + 1 then
        return false;
      fi;
    fi;
    if source[i] = range[i] then
      lastloop := source[i];
      id [ source[i] ] := true;
    fi;
  od;
  return ForAll(id, x -> x = true);
end);

#EOF
