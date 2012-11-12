do (j3) ->
  j3.Queue = Queue = j3.cls
    ctor : ->
      @clear()

    clear : ->
      @_size = 0
      @_front = @_rear = -1
      @_data = []
      @_data.length = 5

    enqueue : (value) ->
      if @_size is @_data.length
        __enlarge.call this

      @_rear = (@_rear + 1) % @_data.length
      @_size += 1
      @_data[@_rear] = value
      return

    dequeue : ->
      if(@_size == 0)
        throw new Error "J3_Err_Queue_Empty"

      # delete the last dequeued entry.
      @_data[@_front] = null

      @_front = (@_front + 1) % @_data.length
      @_size -= 1

      @_data[@_front]

    peek : ->
      if(@_size == 0)
        throw new Error "J3_Err_Queue_Empty"

      @_data[(@_front + 1) % @_data.length]

    getSize : ->
      @_size

  __enlarge = ->
    data = @_data
    max = data.length

    # the space after enlarge
    if max < 10240
      max *= 2
    else
      max += 10240

    data.length = max

    # if not circle, no data need to be moved.
    if @_front < @_rear
      return

    if @_rear + 1 < @_size - @_front - 1
      # move the rear part to new part
      i = 0
      len = @_rear + 1
      while i < len
        # TODO: performance improve here
        data[(@_size + i) % max] = data[i]
        data[i] = null
        i++
      @_rear = (@_rear + @_size) % max
    else
      # move the front part to new part
      i = @_size - 1
      len = max - @_size
      while i > @_front
        data[i + len] = data[i]
        i--
      @_front += len

    return

  Queue.fromArray = (array) ->
    q = new Queue
    q._data = array.concat()
    q._size = array.length
    q
