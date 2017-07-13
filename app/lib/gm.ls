require! {
  'fs'
  'gm'
  'async'
}

exports.resizeAndCrop = (form, file, done) ->
  # Rename the incoming file to the file's name
  fs.rename file.path, form.uploadDir + '/' + file.name
  async.parallel [
    (callback) ->
      # Large image
      size = 
        width: 1200
        height: 800
      gm(form.uploadDir + '/' + file.name)
        .resize(size.width, size.height + '^')
        .gravity('Center')
        .extent(size.width, size.height)
        .quality(80)
        .antialias(false)
        .noProfile()
        .interlace('PlaneInterlace')
        .write form.uploadDir + '/large/' + file.name, (err) ->
          return err if err
          console.log 'Resized to 1200x800'   
          callback null, 'large'
    (callback) ->
      # Small image
      size = do
        width: 400
        height: 300
      gm(form.uploadDir + '/' + file.name)
        .resize(size.width, size.height + '^')
        .gravity('Center').antialias(false)
        .extent(size.width, size.height)
        .quality(80).noProfile()
        .interlace('PlaneInterlace')
        .write form.uploadDir + '/small/' + file.name, (err) ->
          return err if err
          console.log 'Resized to 450x450'
          
          callback null, 'small'
    (callback) ->
      # Avatar image
      size = do
        width: 120
        height: 120
      gm(form.uploadDir + '/' + file.name)
        .resize(size.width, size.height + '^')
        .gravity('Center')
        .antialias(false)
        .extent(size.width, size.height)
        .quality(100)
        .noProfile()
        .interlace('PlaneInterlace')
        .write form.uploadDir + '/tiny/' + file.name, (err) ->
          return err if err
          console.log 'Resized to 120x120 & Cropped'
          
          callback null, 'thumbnail'
    (callback) ->
      # Blur image
      size = do
        width: 1200
        height: 800
      gm(form.uploadDir + '/' + file.name)
        .resize(size.width, size.height + '^')
        .gravity('Center')
        .extent(size.width, size.height)
        .quality(100).blur(30, 20)
        .antialias(true)
        .noProfile()
        .interlace('PlaneInterlace')
        .write form.uploadDir + '/large/blur/' + file.name, (err) ->
          return err if err
          console.log 'Resized to 1200x800 and blured'
          
          callback null, 'blurry'
  ], (err, results) ->
    # the results array will equal ['one','two'] even though
    # the second function had a shorter timeout.
    done()
