function createImg (url) {
  var img = document.createElement('img')
  img.src = url
  document.body.appendChild(img)
}

const ipfs = window.IpfsHttpClient.create({
    host: "207.148.117.14",
    port: "5001",
    protocol: "http",
    timeout: 3000
});

async function show() {
  let cid = document.getElementById("nftpic").value
  console.log(document.getElementById("nftpic").value)
  try{
    let x = []
    for await (const file of ipfs.cat(cid)) {
      console.log(file)
      x.push(file)
      // break
    }
    var url = window.URL.createObjectURL(new Blob(x))
    createImg(url)
  }
  catch (e) {
    console.log(e)
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/resend', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhr.send(`cid=${cid}`)
  }
}
