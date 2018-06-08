
function Out-DataGrid ($properties, $double_click)
{

    $data_grid = New-Object -TypeName System.Windows.Controls.DataGrid -Property @{
        IsReadOnly = $true
        AutoGenerateColumns = $false
    }
                    
    foreach ($elt in $properties)
    {        
        if ($elt.GetType().Name -eq 'String')
        {
            $data_grid.Columns.Add((New-Object -TypeName System.Windows.Controls.DataGridTextColumn `
                -Property @{
                    Header = $elt
                    Binding = (New-Object System.Windows.Data.Binding -ArgumentList @(, $elt))  
                }))
        }
        elseif ($elt.GetType().Name -eq 'Hashtable')
        {
            $setter = New-Object System.Windows.EventSetter -Property @{

                Event = [System.Windows.Documents.Hyperlink]::ClickEvent

                Handler = [System.Windows.RoutedEventHandler] { param($sender, $e) & $elt.handler $data_grid }.GetNewClosure()
            }
                            
            $style = New-Object System.Windows.Style
                
            $style.Setters.Add($setter)
            
            $hyperlink_column = New-Object -TypeName System.Windows.Controls.DataGridHyperlinkColumn -Property @{
                Header = $elt.property
                Binding = New-Object System.Windows.Data.Binding -ArgumentList @(, $elt.property)
                ElementStyle = $style
            }
                        
            if ($elt['width']) { $hyperlink_column.Width = $elt.width }
                        
            $data_grid.Columns.Add($hyperlink_column)                  
        }   
    }
                    
    $data_grid.ItemsSource = @($input)
            
    $grid = New-Object System.Windows.Controls.Grid

    $grid.Children.Add($data_grid) | Out-Null
      
    $window = New-Object System.Windows.Window -Property @{ Content = $grid }

    $window.Title = 'Reddit Links'

    $window.ShowDialog() | Out-Null
    
    $data_grid.SelectedItem
}
