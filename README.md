# rbdig

A DNS lookup library for me to learn how DNS works. Inspired by `dig` CLI tool.
Can encode a domain name in the message and construct a valid DNS query.
Also, it handles decoding of the DNS response raw packet. Currently, it supports only DNS queries for 'A' records.

Can output similar to `dig` (*+noall*, *+short*, *+trace*).

## Usage
Allow execution with `chmod +x dig.rb`.

```
# Recursive lookup, default output
./dig.rb example.com

# Recursive lookup, outputs the steps it takes
./dig.rb -t example.com

# Send a query to the 1.1.1.1 DNS server (Cloudflare's) for example.com
./dig.rb -a 1.1.1.1 example.com
```

Print usage info:
```
./dig.rb -h

Usage: rbdig.rb [options] [DOMAIN] [A]

Specific options:
    -a, --at [SERVER]                Specify the DNS server to query, example: rbdig.rb -a 8.8.8.8 example.com (default: 199.7.83.42)
    -s, --short                      Return only the found IP address (Default: false)
    -n, --noall                      Clears all displayed flags (Default: all)
    -t, --trace                      Enable tracing, showing the iterative queries, disabled when --at specified (Default: false)

Common options:
        --version                    Show version
```

