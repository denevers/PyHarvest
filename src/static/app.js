$( document ).ready( function () {

    $( '#btn-harvest' ).click ( function ( e ) {

        e.preventDefault();

        $( '#status' ).empty();
        $( '#results' ).empty();

        $button = $( this );
        $button.attr( 'disabled', true );
        $( '#status' ).html( '<div id="loading" class="loader"></div> Harvesting in progress...' );

        $.ajax( {
            url: '/harvest',
            data: { id: $( this ).data( 'id' ) },
            type: 'GET',
            success: function( response, status, xhr ) {

                // console.log( response );
                // console.log( status );
                // console.log( xhr.getAllResponseHeaders() );

                var r = response,
                node_list = '<ul><li><a>' + r.nodes.join('</a></li><li>') + '</li></ul>';

                if (status !== 'success') {
                    $( '#status' ).html( 'Harvest failed!' );
                } else {
                    $( '#status' ).html( 'Harvest successful!' );
                    $( '#status' ).after( '<div id="results"><h3>Nodes harvested</h3></div>' );
                    $( '#results' ).append( node_list );
                }

                $button.attr( 'disabled', false );
                
            },
            error: function( error ) {

                var r = error;

                alert( 'ERROR: Harvest failed for some inexplicable reason!' );

                $button.attr( 'disabled', false );
                $( '#status' ).empty();
            }
        } );

    } );

} );