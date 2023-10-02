"""
Basic skeleton of a mitmproxy addon.

"""
from mitmproxy import ctx


class HTTPRewriter:
    def __init__(self):
        self.num = 0

    def response(self, flow):
        ctx.log.info("Host: ")
        ctx.log.info(flow.request.pretty_host)
        if flow.request.pretty_host == "example.com":
            ctx.log.info("Rewriting response from example.com")
            flow.response.content.replace(
                        b"domain", b"dog"
                    )
        self.num = self.num + 1
        ctx.log.info("We've seen %d flows" % self.num)


addons = [HTTPRewriter()]