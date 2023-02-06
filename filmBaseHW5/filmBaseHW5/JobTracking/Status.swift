public enum Status<Output, Failure: Error> {
    case started
    case finished(Result<Output, Failure>)
}
