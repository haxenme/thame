import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Main
{
   public static function main()
   {
      var srcDir = "lame-3.99.5";
      Sys.setCwd("project");
      untar(srcDir, srcDir+".tgz",false,".");
      copy("build.xml", srcDir);
      if (Sys.systemName()=="Windows")
         copy('$srcDir/configMS.h', '$srcDir/config.h');

      runIn(srcDir,"haxelib",["run", "hxcpp", "build.xml"]);
   }

   public static function mkdir(inDir:String)
   {
      FileSystem.createDirectory(inDir);
   }

   public static function untar(inCheckDir:String,inTar:String,inBZ = false,baseDir="unpack")
   {
      if (inCheckDir!="")
      {
         if (FileSystem.exists(inCheckDir+"/.extracted"))
            return;
      }
      Sys.println("untar " + inTar);
      run("tar", [ inBZ ? "xf" : "xzf", "tars/" + inTar, "--no-same-owner", "-C", baseDir ]);
      if (inCheckDir!="")
         File.saveContent(inCheckDir+"/.extracted","extracted");
   }

   public static function run(inExe:String, inArgs:Array<String>)
   {
      trace(inExe + " " + inArgs.join(" "));
      var result = Sys.command(inExe,inArgs);
      if (result != 0)
      {
         Sys.exit(result);
      }
   }

   public static function copy(inFrom:String, inTo:String)
   {
      if (FileSystem.exists(inTo) && FileSystem.isDirectory(inTo))
         inTo += "/" + haxe.io.Path.withoutDirectory(inFrom);

      if (FileSystem.exists(inFrom) && FileSystem.exists(inTo))
      {
         if (File.getContent(inFrom)==File.getContent(inTo))
            return;
      }

      try {
         sys.io.File.copy(inFrom,inTo);
      }
      catch(e:Dynamic)
      {
         Sys.println("Could not copy " + inFrom + " to " + inTo + ":" + e);
         Sys.exit(1);
      }
   }

   public static function copyRecursive(inFrom:String, inTo:String)
   {
      if (!FileSystem.exists(inFrom))
      {
         Sys.println("Invalid copy : " + inFrom);
         Sys.exit(1);
      }
      if (FileSystem.isDirectory(inFrom))
      {
         mkdir(inTo);
         for(file in FileSystem.readDirectory(inFrom))
         {
            if (file.substr(0,1)!=".")
               copyRecursive(inFrom + "/" + file, inTo + "/" + file);
         }

      }
      else
         copy(inFrom,inTo);
   }


   public static function runIn(inDir:String, inExe:String, inArgs:Array<String>)
   {
      var oldPath:String = Sys.getCwd();
      Sys.setCwd(inDir);
      var result = Sys.command(inExe,inArgs);
      if (result != 0)
      {
         Sys.exit(result);
      }
      Sys.setCwd(oldPath);
   }
}


