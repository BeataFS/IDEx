new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("Pt_Address").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()},"${f.get('Address_1')}",/+
      /${f.get('rule')}/)
    }
  }

// Output for patient address
//kept "" for phrases which are likly to contain "," ; if "" are used for other features then the output is given in "" too