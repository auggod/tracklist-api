require! {
  '../models/image': Image
  formidable
  lodash: _
  util
  '../lib/gm': gm  
}

module.exports =
  upload: (req, res) ->
    form = new formidable.IncomingForm do
      uploadDir: require('path').normalize(__dirname + '../../../client/uploads')
    fields = {}
    encoding = 'utf-8'
    keepExtensions = true
    form.on 'file', (file) ->
      _.forEach form.openedFiles, (num, data) ->
        file = form.openedFiles[data]
        file.name = +new Date + Math.random().toString(36).slice(2)
        gm.resizeAndCrop form, file, ->
          # TODO Save image file
          res.json do
            size: file.size
            name: file.name
            type: file.type
    form.on('progress', (bytesReceived, bytesExpected) ->
      console.log 'received: ' + bytesReceived
      percent = bytesReceived / bytesExpected * 100
      io.sockets.emit 'uploadProgress', percent
    ).on('error', (err) ->
      res.writeHead 500, 'content-type': 'text/plain'
      res.end 'error:\n\n' + util.inspect(err)
      console.error err
    ).on('error', (err) ->
      res.writeHead 500, 'content-type': 'text/plain'
      res.end 'error:\n\n' + util.inspect(err)
      console.error err
    ).on('field', (field, value) ->
      fields[field] = value
    ).on 'end', (field, file) ->
      console.log 'Processing...'
    form.parse req
