new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("NHS_number").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()},"${f.get('NHS_Number')}",/+
      /${f.get('rule')}/)
    }
  }