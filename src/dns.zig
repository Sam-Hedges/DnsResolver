// Ref: https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.1

pub const HeaderFlagOpcode = enum(u4) {
    QUERY = 0,
    INVERSE_QUERY = 1,
    STATUS = 2,
    // 3-15 reserved for future use
};

pub const HeaderFlagResponseCode = enum(u4) {
    NO_ERR = 0,
    /// The name server was unable to interpret the query.
    FORMAT_ERR = 1,
    /// The name server was unable to process this query due to a problem with the
    /// name server.
    SERVER_FAILURE = 2,
    /// Meaningful only for responses from an authoritative name server, this code
    /// signifies that the domain name referenced in the query does not exist.
    NAME_ERROR = 3,
    /// The name server does not support the requested kind of query.
    NOT_IMPLEMENTED = 4,
    /// The name server refuses to perform the specified operation for policy
    /// reasons. For example, a name server may not wish to provide the information
    /// to the particular requester, or a name server may not wish to perform a
    /// particular operation (e.g., zone transfer) for particular data.
    REFUSED = 5,
    // 6-15 reserved for future use
};

pub const HeaderFlags = packed union {
    raw: u16,
    data: packed struct {
        /// Specifies whether this message is a query (0), or a response (1).
        query_response: bool,
        /// A four bit field that specifies kind of query in this message. This value
        /// is set by the originator of a query and copied into the response. The
        /// values are:
        /// 0               a standard query (QUERY)
        /// 1               an inverse query (IQUERY)
        /// 2               a server status request (STATUS)
        /// 3-15            reserved for future use
        opcode: HeaderFlagOpcode,
        /// Is valid in responses, and specifies that the responding name server is
        /// an authority for the domain name in question section. The contents of the
        /// answer section may have multiple owner names due to aliases. The AA bit
        /// corresponds to the name which matches the query name, or the first owner
        /// name in the answer section.
        authoritative_answer: bool,
        /// Specifies that this message was truncated due to length greater than
        /// that permitted on the transmission channel.
        truncation: bool,
        /// this bit may be set in a query and is copied into the response. If RD is
        /// set, it directs the name server to pursue the query recursively.
        /// Recursive query support is optional.
        recursion_desired: bool,
        /// This be is set or cleared in a response, and denotes whether recursive
        /// query support is available in the name server.
        recursion_available: bool,
        /// Reserved for future use. Must be zero in all queries and responses.
        _Z: u3 = 0,
        /// This 4 bit field is set as part of responses.
        response_code: HeaderFlagResponseCode,
    },
};

pub const Header = packed struct {
    /// A 16 bit identifier assigned by the program that generates any kind of
    /// query. This identifier is copied the corresponding reply and can be used
    /// by the requester to match up replies to outstanding queries.
    id: u16,
    flags: HeaderFlags,
    /// An unsigned 16 bit integer specifying the number of entries in the
    /// question section.
    question_count: u16,
    /// An unsigned 16 bit integer specifying the number of resource records in
    /// the answer section.
    answer_count: u16,
    /// An unsigned 16 bit integer specifying the number of name server resource
    /// records in the authority records section.
    name_server_count: u16,
    /// An unsigned 16 bit integer specifying the number of resource records in
    /// the additional records section.
    additional_record_count: u16,
};

pub const QuestionRecord = packed struct {
    /// A domain name represented as a sequence of labels, where each label consists
    /// of a length octet followed by that number of octets. The domain name
    /// terminates with the zero length octet for the null label of the root. Note
    /// that this field may be an odd number of octets; no padding is used.
    name: u16,
    /// A two octet code which specifies the type of the query. The values for this
    /// field include all codes valid for a TYPE field, together with some more
    /// general codes which can match more than one type of RR.
    type: u16,
    /// A two octet code that specifies the class of the query. For example, the
    /// QCLASS field is IN for the Internet.
    class: u16,
};

pub const ResourceRecord = packed struct {
    /// A domain name to which this resource record pertains.
    name: u64,
    /// Two octets containing one of the RR type codes. This field specifies the
    /// meaning of the data in the RDATA field.
    type: u16,
    /// Two octets which specify the class of the data in the RDATA field.
    class: u16,
    /// A 32 bit unsigned integer that specifies the time interval (in seconds) that
    /// the resource record may be cached before it should be discarded. Zero values
    /// are interpreted to mean that the RR can only be used for the transaction in
    /// progress, and should not be cached.
    ttl: u32,
    /// An unsigned 16 bit integer that specifies the length in octets of the RDATA
    /// field.
    rdata_length: u16,
    /// A variable length string of octets that describes the resource. The format
    /// of this information varies according to the TYPE and CLASS of the resource
    /// record. For example, the if the TYPE is A and the CLASS is IN, the RDATA
    /// field is a 4 octet ARPA Internet address.
    rdata: u32,
};

pub const Message = packed struct {
    header: Header,
    question_record: QuestionRecord,
    answer_record: ResourceRecord,
    authority_data: ResourceRecord,
    additional_data: ResourceRecord,
};
