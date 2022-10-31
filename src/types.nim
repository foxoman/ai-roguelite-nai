type
  ImageTaskState* = enum
    Created, Pending, Generated
  
  ImageTask* = object
    prompt*: string
    content*: string
    state*: ImageTaskState
  
  ImageBackend* = enum
    NovelAI, AutoWebUI 
  
  Config* = object
    port*: int # local port
    steps*: int
    backend*: ImageBackend 
    uc*: string # negative prompt
    width*: int
    height*: int

    prepend*: string
    append*: string

    # NovelAI-specific
    naiToken*: string
    naiModel*: string

    # AutoWebUI specific
    batchSize*: int
    webuiHost*: string