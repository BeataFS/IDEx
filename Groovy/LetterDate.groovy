new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("LetterDate").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()}, ${f.get('Date')},/+
      /"${f.get('DayDate')}",${f.get('MonthDate')}, ${f.get('YearDate')},/+
      /${f.get('value')},${f.get('rule')}/)
    }
  }