##Fly.io Dashboard Sample Project by Uzo Enudi.

**Note:** This project was built on a copy of the Fly.io [sample project](https://github.com/fly-hiring/phoenix-full-stack-work-sample).

###What is built
A minimal LiveView dashboard implementation of [flyctl status](https://fly.io/docs/flyctl/status/) using the relevant GraphQl API call.The dashboard:
- fetch and show the status details of application set to it.
- Show allocated application resources on the side bar.
- Reorganize the info "widgets" in a way that matters to the user-- allocated resource should come first before activity feed or timeline.
- Dashboard data is updated at certain interval-- 20 secs as default in this project.
- A bit of design tweak to make it look nicer.

###What is left out
**Deployment status:** An inline ephemeral message showing the most recent deployment details, if available. This
could be done with LiveView `put_flash/3`.

**Postgresql resources:** Health check output returns useful allocated resources like available free space that
require a fairly complex pattern-matching to extract.

**Homepage update:** Live updates for the homepage listing was not implemented.

**Type specs:** `@spec` was left out of function definitions for legibility.

###Future Improvement and Fixes
- A better novice-friendly look-and-feel user interface.
- App instances needs a dedicated page because the list can get really long on mulitiple deployments, or:
- A fixed right-sidebar showing critical resource summary with a scrollable app left-side content area for a possible long apps list.
- Better menu system-- instead of relying on breadcrumb for it's restrictive linear navigation.
- Better code organization
- Have the homepage and other pages share a common root template for`<header>brand and menu bar</header>`

### Evidence for Successful execution
**Logger:** Using Loggers extensively during development to help ensure that outputs are returning the right results at runtime.

**Counter** Implemented an `update_counter` to keep track of dashboard updates counts. The counter could be found
at the bottom of the right-sidebar labeled "Live Refresh" on the instance page. Default interval is 20 secs.





