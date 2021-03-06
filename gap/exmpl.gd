#############################################################################
##
##  exmpl.gd
##  Copyright (C) 2019                                     Murray T. Whyte
##                                                       James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructors for certain standard examples of digraphs.

DeclareConstructor("EmptyDigraphCons", [IsDigraph, IsInt]);
DeclareOperation("EmptyDigraph", [IsInt]);
DeclareOperation("EmptyDigraph", [IsFunction, IsInt]);
DeclareSynonym("NullDigraph", EmptyDigraph);

DeclareConstructor("CompleteBipartiteDigraphCons",
                   [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("CompleteBipartiteDigraph", [IsPosInt, IsPosInt]);
DeclareOperation("CompleteBipartiteDigraph", [IsFunction, IsPosInt, IsPosInt]);

DeclareConstructor("CompleteMultipartiteDigraphCons", [IsDigraph, IsList]);
DeclareOperation("CompleteMultipartiteDigraph", [IsList]);
DeclareOperation("CompleteMultipartiteDigraph", [IsFunction, IsList]);

DeclareConstructor("CompleteDigraphCons", [IsDigraph, IsInt]);
DeclareOperation("CompleteDigraph", [IsInt]);
DeclareOperation("CompleteDigraph", [IsFunction, IsInt]);

DeclareConstructor("CycleDigraphCons", [IsDigraph, IsPosInt]);
DeclareOperation("CycleDigraph", [IsPosInt]);
DeclareOperation("CycleDigraph", [IsFunction, IsPosInt]);

DeclareConstructor("ChainDigraphCons", [IsDigraph, IsPosInt]);
DeclareOperation("ChainDigraph", [IsPosInt]);
DeclareOperation("ChainDigraph", [IsFunction, IsPosInt]);

DeclareConstructor("JohnsonDigraphCons", [IsDigraph, IsInt, IsInt]);
DeclareOperation("JohnsonDigraph", [IsInt, IsInt]);
DeclareOperation("JohnsonDigraph", [IsFunction, IsInt, IsInt]);

DeclareConstructor("PetersenGraphCons", [IsDigraph]);
DeclareOperation("PetersenGraph", []);
DeclareOperation("PetersenGraph", [IsFunction]);
