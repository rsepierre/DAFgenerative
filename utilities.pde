String fileBasename(String fileName) {
   int slashIndex = fileName.lastIndexOf('/');
   if(slashIndex == -1) { slashIndex = 0; }
   int dotIndex = fileName.lastIndexOf('.');
   if(dotIndex == -1) { slashIndex = fileName.length(); }
   return fileName.substring(slashIndex, dotIndex);
 }
