ACCOUNT="your account"        # your evernote account name
CHECK_INTERVAL=2          # content update check interval (sec)
MARKED_REFRESH_BG=yes     # [yes/no] yes:background, no:background
VERBOSE=no                # [yes/no] yes:check result output, no:silent


CONTENT_DIR="${HOME}/Library/Containers/com.evernote.Evernote/Data/Library/Application Support/com.evernote.Evernote/accounts/www.evernote.com/${ACCOUNT}/content"
CONTENT_HTML=content.enml # read file
CONTENT_MD=content.md     # write file


while true;
do
  LATEST_DIR=`stat -l -t '%FT%T' "${CONTENT_DIR}"/* | cut -d' ' -f6- | sort | tail -1 | cut -d' ' -f2-`
  NEW_HASH=`md5 "${LATEST_DIR}/${CONTENT_HTML}" | cut -d= -f2`
  if [ "${HASH}"x == "${NEW_HASH}"x ]; then
    test "${VERBOSE}"x == "yes"x && echo "content not been updated."
    sleep ${CHECK_INTERVAL}
    continue
  fi

  HASH=${NEW_HASH}
  cat "${LATEST_DIR}/${CONTENT_HTML}" | sed -e 's/<img src=\"\([^"]*\)\"[^>]*>/![](\1)/g' | textutil -stdin -format html -convert txt -stdout >"${LATEST_DIR}/${CONTENT_MD}"
  test "${VERBOSE}"x == "yes"x && echo "content updated, refresh markdown."
  open -a Marked "${LATEST_DIR}/${CONTENT_MD}" $(test "${MARKED_REFRESH_FG}"x != "yes"x && echo '-g')
  sleep ${CHECK_INTERVAL}
done
