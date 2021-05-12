#!/bin/bash
#위에 #! 앞에 공백 있으니 오류나서 적용안됨 꼭 앞에 공백없이 작성 할 것 !!!
cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup busybox httpd -f -p "${server_port}" &yes
