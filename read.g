#############################################################################
##
##  read.g
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

if not DIGRAPHS_IsGrapeLoaded then
  Add(DIGRAPHS_OmitFromTests, "Graph(");
fi;

_NautyTracesInterfaceVersion :=
  First(PackageInfo("digraphs")[1].Dependencies.SuggestedOtherPackages,
        x -> x[1] = "nautytracesinterface")[2];

BindGlobal("DIGRAPHS_NautyAvailable",
  IsPackageMarkedForLoading("NautyTracesInterface",
                            _NautyTracesInterfaceVersion));

Unbind(_NautyTracesInterfaceVersion);

ReadPackage("digraphs", "gap/utils.gi");
ReadPackage("digraphs", "gap/digraph.gi");
ReadPackage("digraphs", "gap/cnstr.gi");
ReadPackage("digraphs", "gap/grape.gi");
ReadPackage("digraphs", "gap/labels.gi");
ReadPackage("digraphs", "gap/attr.gi");
ReadPackage("digraphs", "gap/prop.gi");
ReadPackage("digraphs", "gap/oper.gi");
ReadPackage("digraphs", "gap/display.gi");
ReadPackage("digraphs", "gap/isomorph.gi");
ReadPackage("digraphs", "gap/io.gi");
ReadPackage("digraphs", "gap/grahom.gi");
ReadPackage("digraphs", "gap/orbits.gi");
ReadPackage("digraphs", "gap/cliques.gi");
ReadPackage("digraphs", "gap/planar.gi");
ReadPackage("digraphs", "gap/exmpl.gi");

MakeReadWriteGlobal("IO_CompressedFile");

IO_CompressedFile :=
function(arg)
  # arguments: filename [,mode][,bufsize]
  # mode and bufsize as in IO_File
  local bufsize,f,fd,filename,mode,r,ext,splitname,extension,compressor,file;
  if Length(arg) = 1 then
      filename := arg[1];
      mode := "r";
      bufsize := IO.DefaultBufSize;
  elif Length(arg) = 2 then
      filename := arg[1];
      if IsString(arg[2]) then
          mode := arg[2];
          bufsize := IO.DefaultBufSize;
      else
          mode := "r";
          bufsize := arg[2];
      fi;
  elif Length(arg) = 3 then
      filename := arg[1];
      mode := arg[2];
      bufsize := arg[3];
  else
      Error("IO: Usage: IO_CompressedFile( filename [,mode][,bufsize] )\n",
            "with IsString(filename)");
  fi;
  if not(IsString(filename)) and not(IsString(mode)) then
      Error("IO: Usage: IO_CompressedFile( filename [,mode][,bufsize] )\n",
            "with IsString(filename)");
  fi;


  splitname := SplitString(filename, ".");
  extension := splitname[Length(splitname)];

  Print("1:",splitname, ":", extension, "\n");
  # compressor format: ["executable", args for compression, args for uncompression]
  if extension = "gz" then
      compressor := ["gzip",["-9q"],["-dq"]];
  elif extension = "bz2" then
      compressor := ["bzip2",["-9q"],["-dq"]];
  elif extension = "xz" then
      # xz higher than 6 is not really worth the time / space tradeoff
      compressor := ["xz",["-6q"],["-dq"]];
  else
      return IO_File(filename,mode,bufsize);
  fi;
  Print("2:",compressor, filename, mode, bufsize,"\n");

  if mode = "r" then
      file := IO_FilteredFile([[compressor[1], compressor[3]]], filename, mode, bufsize);
  else
      file := IO_FilteredFile([[compressor[1], compressor[2]]], filename, mode, bufsize);
  fi;

  if file <> fail then
      return file;
  fi;

  Print("3:", file,"\n");

  # Oops, something went wrong. Let's see if the problem is the compression prog
  if IO_FindExecutable(compressor[1]) = fail then
      Error("Cannot find '",compressor[1],
            "', required for "+extension+" files in IO_CompressedFile");
  fi;
  #Nope, then just return fail
  return fail;

end;
