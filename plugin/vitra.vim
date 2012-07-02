if exists("g:vitra_loaded") || !exists('g:tracServerList') || g:tracServerList == {}
    finish
endif

if !has("python")
    echo 'vitra requires vim compiled with +python.'
    finish
endif

python << EOF
import sys
if sys.version_info[:2] < (2, 6):
    print("vitra requires python 2.6 or later to work correctly")
    vim.command('let s:pythonVersion = 1')
EOF

if exists('s:pythonVersion')
    finish
endif

let g:vitra_loaded = 1

fun s:vitraDefault(name, default)
    if !exists(a:name)
        let {a:name} = a:default
    endif
endfun

call s:vitraDefault('g:tracDefaultServer', '')
call s:vitraDefault('g:tracDefaultComment', 'Updated from Vitra')
call s:vitraDefault('g:tracTempHtml', '/tmp/trac_wiki.html')

call s:vitraDefault('g:tracTicketClause', 'status!=closed')
call s:vitraDefault('g:tracTicketGroup', 'milestone')
call s:vitraDefault('g:tracTicketOrder', 'priority')

call s:vitraDefault('g:tracWikiStyle', 'full')
call s:vitraDefault('g:tracWikiPreview', 1)
call s:vitraDefault('g:tracWikiToC', 1)
call s:vitraDefault('g:tracHideTracWiki', 1)

call s:vitraDefault('g:tracTicketStyle', 'full')
call s:vitraDefault('g:tracTicketFormat', 1)

call s:vitraDefault('g:tracTimelineMax', 50)

com! -nargs=? -complete=customlist,ComTracServers TracServer  python trac.set_server(<q-args>)

com! -nargs=? -complete=customlist,ComWiki TWOpen python trac.wiki_view(<q-args>)
com! -nargs=0 TWClose python trac.uiwiki.destroy()
com! -nargs=* TWSave python trac.save_wiki(<q-args>)
com! -nargs=0 TWInfo python print trac.wiki.current

com! -nargs=? -complete=customlist,ComTicket TTOpen python trac.ticket_view(<q-args>)
com! -nargs=0 TTClose python trac.uiticket.destroy()

com! -nargs=0 TTEditSummary python trac.load_current('summary')
com! -nargs=0 TTEditDescription python trac.load_current('description')
com! -nargs=0 TTSetSummary python trac.update_ticket('summary')
com! -nargs=0 TTSetDescription python trac.update_ticket('description')
com! -nargs=0 TTAddComment python trac.update_ticket('comment')

com! -nargs=0 TTClearAllFilters python trac.filter_clear()
com! -nargs=? -complete=customlist,ComSort TTClearFilter python trac.filter_clear(<q-args>)

com! -nargs=? -complete=customlist,ComSort TTOrderBy python trac.sort_ticket('order', <q-args>)
com! -nargs=? -complete=customlist,ComSort TTGroupBy python trac.sort_ticket('group', <q-args>)

com! -nargs=0 TTNextPage python trac.ticket_paginate()
com! -nargs=0 TTPreviousPage python trac.ticket_paginate(-1)
com! -nargs=0 TTFirstPage python trac.ticket.page = 1; trac.ticket_view()
com! -nargs=0 TTLastPage python trac.ticket.page = trac.ticket.total_pages; trac.ticket_view()

com! -nargs=+ -complete=customlist,ComAction TTAction python trac.act_ticket(<q-args>)

com! -nargs=* -complete=customlist,ComTracType TTimeline python trac.timeline_view(<f-args>)
com! -nargs=+ TSearch python trac.search_view(<q-args>)
com! -nargs=1 TChangeset python trac.changeset_view(<q-args>)
com! -nargs=0 TServer python trac.server_view()

com! -nargs=? -complete=file TAddAttachment python trac.add_attachment(<q-args>)
com! -nargs=0 TPreview python trac.preview()
com! -nargs=0 TBack python trac.back()
com! -nargs=0 TForward python trac.back(True)

fun ComTracServers(A, L, P)
    return filter(keys(g:tracServerList), 'v:val =~ "^' . a:A . '"')
endfun

fun ComTracType(A, L, P)
    return filter(['wiki', 'ticket', 'changeset'], 'v:val =~ "^' . a:A . '"')
endfun

fun ComWiki(A, L, P)
    python trac.wiki.get_options()
    return filter(g:tracOptions, 'v:val =~ "^' . a:A . '"')
endfun

fun ComTicket(A, L, P)
    python trac.ticket.get_options(type_='history')
    return filter(g:tracOptions, 'v:val =~ "^' . a:A . '"')
endfun

fun ComSort(A, L, P)
    python trac.ticket.get_options(type_='field')
    return filter(g:tracOptions, 'v:val =~ "^' . a:A . '"')
endfun

fun ComAction(A, L, P)
    python trac.ticket.get_options(type_='action')
    return filter(g:tracOptions, 'v:val =~ "^' . a:A . '"')
endfun

pyfile <sfile>:p:h/vitra.py
python trac_init()
