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
      compressor := ["gzip",["-9"],["-d"]];
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
        Print("2a:", compressor[1], ":", compressor[3],"\n");
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

MakeReadWriteGlobal("IO_FilteredFile");

IO_FilteredFile :=
function(arg)
  # arguments: progs, filename [,mode][,bufsize]
  # mode and bufsize as in IO_File, progs as for StartPipeline
  local bufsize,f,fd,filename,mode,progs,r;
  if Length(arg) = 2 then
      progs := arg[1];
      filename := arg[2];
      mode := "r";
      bufsize := IO.DefaultBufSize;
  elif Length(arg) = 3 then
      progs := arg[1];
      filename := arg[2];
      if IsString(arg[3]) then
          mode := arg[3];
          bufsize := IO.DefaultBufSize;
      else
          mode := "r";
          bufsize := arg[3];
      fi;
  elif Length(arg) = 4 then
      progs := arg[1];
      filename := arg[2];
      mode := arg[3];
      bufsize := arg[4];
  else
      Error("IO: Usage: IO_FilteredFile( progs,filename [,mode][,bufsize] )\n",
            "with IsString(filename)");
  fi;
  if not(IsString(filename)) and not(IsString(mode)) then
      Error("IO: Usage: IO_FilteredFile( progs, filename [,mode][,bufsize] )\n",
            "with IsString(filename)");
  fi;
  Print("x1:", filename, mode, progs, bufsize,"\n");
  if Length(progs) = 0 then
      return IO_File(filename,mode,bufsize);
  fi;
  if mode = "r" then
    Print("x2:", filename, mode, progs, bufsize,"\n");

      fd := IO_open(filename,IO.O_RDONLY,0);
      Print("x3:", fd,"\n");
      if fd = fail then return fail; fi;
      r := IO_StartPipeline(progs,fd,"open",false);
      Print("x4:", r,"\n");
      if r = fail or fail in r.pids then
          IO_close(fd);
          return fail;
      fi;
      f := IO_WrapFD(r.stdout,bufsize,false);
      SetProcessID(f,r.pids);
      f!.dowaitpid := true;
  else
      if mode = "w" then
          fd := IO_open(filename,IO.O_CREAT+IO.O_WRONLY+IO.O_TRUNC,
                        IO.S_IRUSR+IO.S_IWUSR+IO.S_IRGRP+IO.S_IWGRP+
                        IO.S_IROTH+IO.S_IWOTH);
      else
          fd := IO_open(filename,IO.O_WRONLY + IO.O_APPEND,
                        IO.S_IRUSR+IO.S_IWUSR+IO.S_IRGRP+IO.S_IWGRP+
                        IO.S_IROTH+IO.S_IWOTH);
      fi;
      if fd = fail then return fail; fi;
      r := IO_StartPipeline(progs, "open", fd, false);
      if r = fail or fail in r.pids then
          IO_close(fd);
          return fail;
      fi;
      f := IO_WrapFD(r.stdin,false,bufsize);
      SetProcessID(f,r.pids);
      f!.dowaitpid := true;
  fi;
  Print("x5:", f,"\n");
  return f;
end;
