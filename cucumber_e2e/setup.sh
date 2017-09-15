#!/bin/bash

# Change to path to your web driver
MYDRIVER=/usr/lib/chromium-browser

export PATH="$PATH:$MYDRIVER"

npm install

./node_modules/.bin/webdriver-manager update --standalone

cat > startup-server.sh <<EOF
#!/bin/bash

export PATH="\$PATH:$MYDRIVER"

./node_modules/.bin/webdriver-manager start &
EOF

cat > run-test.sh <<EOF
#!/bin/bash

export PATH="\$PATH:$MYDRIVER"

npm test
EOF

cat > stop-server.sh <<EOF
#!/bin/bash

curl -s -L http://localhost:4444/selenium-server/driver?cmd=shutDownSeleniumServer
EOF

chmod u+x startup-server.sh run-test.sh stop-server.sh

./startup-server.sh
